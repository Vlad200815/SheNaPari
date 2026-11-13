using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Orders;

public class OrderService(AppDbContext db, CampusClock clock, OrderNotifier notifier)
{
    private const int MaxQuantity = 20;

    // ---------- client ----------

    /// Creates an order that is already paid (payment is simulated) and puts it on the kitchen's board.
    public async Task<Result<OrderDto>> CreateAsync(Guid customerId, CreateOrderDto dto)
    {
        if (dto.Items.Count == 0) return OrderErrors.Empty;
        if (dto.Items.Any(i => i.Quantity is < 1 or > MaxQuantity)) return OrderErrors.InvalidQuantity;
        if (dto.PaymentProvider is not { } provider) return OrderErrors.PaymentRequired;

        var canteen = await db.Canteens.FirstAsync();
        if (!canteen.IsAcceptingOrders) return OrderErrors.CanteenPaused;

        var now = clock.UtcNow;
        if (dto.BreakSlotId is { } slotId)
        {
            var slot = await db.BreakSlots.FindAsync(slotId);
            if (slot is null) return OrderErrors.BreakNotFound;
            if (slot.StartsAt <= now) return OrderErrors.BreakPassed;
        }

        // Names and prices come from the DB, never from the client.
        var dishIds = dto.Items.Select(i => i.DishId).Distinct().ToList();
        var dishes = await db.Dishes
            .Where(d => dishIds.Contains(d.Id) && d.IsAvailable)
            .ToDictionaryAsync(d => d.Id);
        if (dishes.Count != dishIds.Count) return OrderErrors.DishUnavailable;

        var items = dto.Items
            .GroupBy(i => i.DishId) // same dish twice in the request → one line
            .Select(g => new OrderItem
            {
                DishId = g.Key,
                Quantity = g.Sum(i => i.Quantity),
                NameSnapshot = dishes[g.Key].Name,
                UnitPrice = dishes[g.Key].Price,
            })
            .ToList();
        if (items.Any(i => i.Quantity > MaxQuantity)) return OrderErrors.InvalidQuantity;
        var total = items.Sum(i => i.UnitPrice * i.Quantity);

        var (dayStart, dayEnd) = clock.DayRangeUtc(clock.Today);
        var order = new Order
        {
            CustomerId = customerId,
            BreakSlotId = dto.BreakSlotId,
            // Short number restarts every day: "#7" is easy to call out at the counter.
            Number = await db.Orders.CountAsync(o => o.CreatedAt >= dayStart && o.CreatedAt < dayEnd) + 1,
            PickupToken = new Guid(RandomNumberGenerator.GetBytes(16)),
            Total = total,
            CreatedAt = now,
            Items = items,
            Payments =
            [
                new Payment
                {
                    Provider = provider, Amount = total, Status = PaymentStatus.Paid,
                    CreatedAt = now, PaidAt = now,
                },
            ],
        };
        SetStatus(order, OrderStatus.Paid, customerId);
        db.Orders.Add(order);
        await db.SaveChangesAsync();

        var loaded = (await LoadAsync(order.Id))!;
        await notifier.OrderCreatedAsync(ToStaffDto(loaded));
        return ToClientDto(loaded);
    }

    public async Task<List<OrderDto>> GetMyAsync(Guid customerId)
    {
        var list = await Query()
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
        return list.Select(ToClientDto).ToList();
    }

    /// Only the owner may see an order; anyone else gets "not found" (not 403, to not leak ids).
    public async Task<Result<OrderDto>> GetMineByIdAsync(Guid customerId, Guid orderId)
    {
        var order = await Query().FirstOrDefaultAsync(o => o.Id == orderId && o.CustomerId == customerId);
        return order is null ? OrderErrors.NotFound : ToClientDto(order);
    }

    /// The client changes their mind. Possible only until the kitchen starts cooking.
    public async Task<Result<OrderDto>> CancelByCustomerAsync(Guid customerId, Guid orderId)
    {
        var order = await Query().FirstOrDefaultAsync(o => o.Id == orderId && o.CustomerId == customerId);
        if (order is null) return OrderErrors.NotFound;
        if (!OrderStatusRules.CanMove(order.Status, OrderStatus.Cancelled)) return OrderErrors.CannotCancel;

        Cancel(order, customerId, "Скасовано клієнтом");
        await db.SaveChangesAsync();
        await notifier.StatusChangedAsync(order);
        return ToClientDto(order);
    }

    // ---------- staff ----------

    /// The kitchen's board: orders still in work that are "as soon as possible" or for a break today.
    public async Task<List<StaffOrderDto>> GetActiveAsync()
    {
        var (_, endOfToday) = clock.DayRangeUtc(clock.Today);
        var list = await Query()
            .Where(o => o.Status == OrderStatus.Paid || o.Status == OrderStatus.Accepted
                     || o.Status == OrderStatus.Cooking || o.Status == OrderStatus.Ready)
            .Where(o => o.BreakSlot == null || o.BreakSlot.StartsAt < endOfToday)
            .ToListAsync();
        return list
            .OrderBy(o => o.BreakSlot?.StartsAt ?? o.CreatedAt) // what is needed sooner comes first
            .ThenBy(o => o.Number)
            .Select(ToStaffDto)
            .ToList();
    }

    /// Every order created on the given campus day, finished ones included (admin view).
    public async Task<List<StaffOrderDto>> GetByDayAsync(DateOnly day)
    {
        var (from, to) = clock.DayRangeUtc(day);
        var list = await Query()
            .Where(o => o.CreatedAt >= from && o.CreatedAt < to)
            .OrderBy(o => o.CreatedAt)
            .ToListAsync();
        return list.Select(ToStaffDto).ToList();
    }

    /// "Прийняти": the cook takes the order and promises a time.
    public async Task<Result<StaffOrderDto>> AcceptAsync(Guid staffId, Guid orderId, int minutes)
    {
        if (!OrderStatusRules.EtaOptions.Contains(minutes)) return OrderErrors.InvalidEta;
        var order = await LoadAsync(orderId);
        if (order is null) return OrderErrors.NotFound;
        if (!OrderStatusRules.CanMove(order.Status, OrderStatus.Accepted)) return OrderErrors.InvalidTransition;

        var eta = clock.UtcNow.AddMinutes(minutes);
        // An order for a break is expected at the break, not earlier.
        if (order.BreakSlot is { } slot && slot.StartsAt > eta) eta = slot.StartsAt;
        order.EstimatedReadyAt = eta;
        SetStatus(order, OrderStatus.Accepted, staffId);
        await db.SaveChangesAsync();
        await notifier.StatusChangedAsync(order);
        return ToStaffDto(order);
    }

    /// Cooking, Ready, Cancelled, NotPickedUp and (if the QR can't be scanned) PickedUp.
    public async Task<Result<StaffOrderDto>> ChangeStatusAsync(Guid staffId, Guid orderId, OrderStatus to, string? reason)
    {
        if (to == OrderStatus.Accepted) return OrderErrors.EtaRequired; // use AcceptAsync
        var order = await LoadAsync(orderId);
        if (order is null) return OrderErrors.NotFound;
        if (!OrderStatusRules.CanMove(order.Status, to)) return OrderErrors.InvalidTransition;

        reason = string.IsNullOrWhiteSpace(reason) ? null : reason.Trim();
        if (to == OrderStatus.Cancelled) Cancel(order, staffId, reason ?? "Скасовано кухнею");
        else SetStatus(order, to, staffId, reason);
        await db.SaveChangesAsync();
        await notifier.StatusChangedAsync(order);
        return ToStaffDto(order);
    }

    /// Staff scanned the client's QR. Only a Ready order can be handed out, and only once.
    public async Task<Result<StaffOrderDto>> PickupAsync(Guid staffId, Guid token)
    {
        var id = await db.Orders.Where(o => o.PickupToken == token).Select(o => (Guid?)o.Id).FirstOrDefaultAsync();
        var order = id is null ? null : await LoadAsync(id.Value);
        if (order is null) return OrderErrors.NotFound;
        if (order.Status == OrderStatus.PickedUp) return OrderErrors.AlreadyPickedUp;
        if (order.Status != OrderStatus.Ready) return OrderErrors.NotReady;

        SetStatus(order, OrderStatus.PickedUp, staffId);
        await db.SaveChangesAsync();
        await notifier.StatusChangedAsync(order);
        return ToStaffDto(order);
    }

    // ---------- system (timer) ----------

    /// Ready orders nobody came for within the limit are closed as NotPickedUp. Returns how many.
    public async Task<int> ExpireNotPickedUpAsync(TimeSpan limit)
    {
        var deadline = clock.UtcNow - limit;
        var expired = await Query()
            .Where(o => o.Status == OrderStatus.Ready && o.ReadyAt != null && o.ReadyAt <= deadline)
            .ToListAsync();
        foreach (var order in expired)
            SetStatus(order, OrderStatus.NotPickedUp, changedBy: null,
                $"Не забрано протягом {(int)limit.TotalMinutes} хв");
        await db.SaveChangesAsync();
        foreach (var order in expired) await notifier.StatusChangedAsync(order);
        return expired.Count;
    }

    // ---------- helpers ----------

    /// The single place where a status changes: it also writes the history line.
    private void SetStatus(Order order, OrderStatus status, Guid? changedBy, string? reason = null)
    {
        var now = clock.UtcNow;
        order.Status = status;
        if (status == OrderStatus.Ready) order.ReadyAt = now;
        order.StatusChanges.Add(new OrderStatusChange
        {
            Status = status, ChangedByUserId = changedBy, Reason = reason, At = now,
        });
    }

    /// Cancelling always refunds the (simulated) payment.
    private void Cancel(Order order, Guid changedBy, string reason)
    {
        foreach (var p in order.Payments.Where(p => p.Status == PaymentStatus.Paid))
            p.Status = PaymentStatus.Refunded;
        SetStatus(order, OrderStatus.Cancelled, changedBy, reason);
    }

    private IQueryable<Order> Query() => db.Orders
        .Include(o => o.Customer)
        .Include(o => o.BreakSlot)
        .Include(o => o.Items)
        .Include(o => o.StatusChanges)
        .Include(o => o.Payments)
        .AsSplitQuery(); // several collections: separate SELECTs instead of one huge JOIN

    private Task<Order?> LoadAsync(Guid id) => Query().FirstOrDefaultAsync(o => o.Id == id);

    private static BreakSlotDto? ToSlotDto(BreakSlot? b) => b is null ? null : new(b.Id, b.StartsAt, b.EndsAt);

    private static List<OrderItemDto> ToItemDtos(Order o) =>
        o.Items.Select(i => new OrderItemDto(i.DishId, i.NameSnapshot, i.Quantity, i.UnitPrice)).ToList();

    private static List<OrderStatusChangeDto> ToHistory(Order o) =>
        o.StatusChanges.OrderBy(c => c.At).ThenBy(c => c.Id)
            .Select(c => new OrderStatusChangeDto(c.Status, c.At, c.Reason)).ToList();

    private static OrderDto ToClientDto(Order o) => new(
        o.Id, o.Number, o.Status, o.Total, o.CreatedAt, ToSlotDto(o.BreakSlot), o.EstimatedReadyAt, o.ReadyAt,
        o.Payments.OrderBy(p => p.CreatedAt).Last().Provider, ToItemDtos(o), ToHistory(o),
        o.Status == OrderStatus.Ready ? o.PickupToken : null);

    private static StaffOrderDto ToStaffDto(Order o) => new(
        o.Id, o.Number, o.Status, o.Total, o.Customer.Name, o.CreatedAt, ToSlotDto(o.BreakSlot),
        o.EstimatedReadyAt, o.ReadyAt, ToItemDtos(o), ToHistory(o));
}
