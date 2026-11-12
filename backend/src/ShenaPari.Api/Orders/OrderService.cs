using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Menu;

namespace ShenaPari.Api.Orders;

public class OrderService(AppDbContext db, CampusClock clock, IHubContext<OrdersHub> hub)
{
    private const int MaxQuantity = 20;

    // ---------- client ----------

    public async Task<Result<OrderDto>> CreateAsync(Guid userId, CreateOrderDto dto)
    {
        if (dto.Items.Count == 0) return OrderErrors.Empty;
        if (dto.Items.Any(i => i.Quantity is < 1 or > MaxQuantity))
            return OrderErrors.InvalidQuantity;

        var slot = await db.BreakSlots.FindAsync(dto.BreakSlotId);
        if (slot is null) return OrderErrors.BreakNotFound;
        if (slot.OrderDeadline <= clock.UtcNow) return OrderErrors.DeadlinePassed;

        // Prices come from the DB, never from the client.
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
                UnitPrice = dishes[g.Key].Price,
            })
            .ToList();

        var order = new Order
        {
            CustomerId = userId,
            BreakSlotId = slot.Id,
            // Short number restarts for every break: "#7" is easy to call out.
            Number = await db.Orders.CountAsync(o => o.BreakSlotId == slot.Id) + 1,
            PickupToken = new Guid(RandomNumberGenerator.GetBytes(16)),
            Status = OrderStatus.Pending,
            Total = items.Sum(i => i.UnitPrice * i.Quantity),
            CreatedAt = clock.UtcNow,
            Items = items,
        };
        db.Orders.Add(order);
        await db.SaveChangesAsync();

        var staffView = await LoadStaffDtoAsync(order.Id);
        await hub.Clients.Group(OrdersHub.StaffGroup).SendAsync("OrderCreated", staffView);

        return (await LoadClientDtoAsync(order.Id))!;
    }

    public async Task<List<OrderDto>> GetMyAsync(Guid userId)
    {
        var list = await ClientQuery()
            .Where(o => o.CustomerId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
        return list.Select(ToClientDto).ToList();
    }

    /// Only the owner may see an order; anyone else gets "not found" (not 403, to not leak ids).
    public async Task<OrderDto?> GetMineByIdAsync(Guid userId, Guid orderId)
    {
        var order = await ClientQuery().FirstOrDefaultAsync(o => o.Id == orderId && o.CustomerId == userId);
        return order is null ? null : ToClientDto(order);
    }

    // ---------- staff ----------

    /// Active orders; for one break if breakSlotId is given, otherwise for today.
    public async Task<List<StaffOrderDto>> GetForStaffAsync(int? breakSlotId)
    {
        var query = StaffQuery();
        if (breakSlotId is not null)
        {
            query = query.Where(o => o.BreakSlotId == breakSlotId);
        }
        else
        {
            var (from, to) = clock.DayRangeUtc(clock.Today);
            query = query.Where(o => o.BreakSlot.StartsAt >= from && o.BreakSlot.StartsAt < to);
        }

        var list = await query
            .Where(o => o.Status != OrderStatus.PickedUp && o.Status != OrderStatus.Cancelled)
            .OrderBy(o => o.BreakSlot.StartsAt).ThenBy(o => o.Number)
            .ToListAsync();
        return list.Select(ToStaffDto).ToList();
    }

    public async Task<Result<StaffOrderDto>> ChangeStatusAsync(Guid orderId, OrderStatus to)
    {
        var order = await db.Orders.FindAsync(orderId);
        if (order is null) return OrderErrors.NotFound;
        if (!OrderStatusRules.CanMove(order.Status, to))
            return OrderErrors.InvalidTransition;

        order.Status = to;
        await db.SaveChangesAsync();
        await NotifyStatusAsync(order);
        return (await LoadStaffDtoAsync(order.Id))!;
    }

    /// Staff scanned the client's QR. Only a Ready order can be handed out, and only once.
    public async Task<Result<StaffOrderDto>> PickupAsync(Guid token)
    {
        var order = await db.Orders.FirstOrDefaultAsync(o => o.PickupToken == token);
        if (order is null) return OrderErrors.NotFound;
        if (order.Status == OrderStatus.PickedUp) return OrderErrors.AlreadyPickedUp;
        if (order.Status != OrderStatus.Ready) return OrderErrors.NotReady;

        order.Status = OrderStatus.PickedUp;
        await db.SaveChangesAsync();
        await NotifyStatusAsync(order);
        return (await LoadStaffDtoAsync(order.Id))!;
    }

    // ---------- helpers ----------

    private Task NotifyStatusAsync(Order order)
    {
        var evt = new OrderStatusChangedEvent(order.Id, order.Status);
        return hub.Clients
            .Groups(OrdersHub.UserGroup(order.CustomerId), OrdersHub.StaffGroup)
            .SendAsync("OrderStatusChanged", evt);
    }

    private IQueryable<Order> ClientQuery() =>
        db.Orders.Include(o => o.BreakSlot).Include(o => o.Items).ThenInclude(i => i.Dish);

    private IQueryable<Order> StaffQuery() => ClientQuery().Include(o => o.Customer);

    // Load entities first, then map in memory: Include + a C# mapping method inside
    // Select() is something EF Core may not translate the way you expect.
    private async Task<OrderDto?> LoadClientDtoAsync(Guid id)
    {
        var o = await ClientQuery().FirstOrDefaultAsync(x => x.Id == id);
        return o is null ? null : ToClientDto(o);
    }

    private async Task<StaffOrderDto?> LoadStaffDtoAsync(Guid id)
    {
        var o = await StaffQuery().FirstOrDefaultAsync(x => x.Id == id);
        return o is null ? null : ToStaffDto(o);
    }

    private static BreakSlotDto ToSlotDto(BreakSlot b) => new(b.Id, b.StartsAt, b.EndsAt, b.OrderDeadline);

    private static List<OrderItemDto> ToItemDtos(Order o) =>
        o.Items.Select(i => new OrderItemDto(i.DishId, i.Dish.Name, i.Quantity, i.UnitPrice)).ToList();

    private static OrderDto ToClientDto(Order o) => new(
        o.Id, o.Number, o.Status, o.Total, o.CreatedAt, ToSlotDto(o.BreakSlot), ToItemDtos(o),
        o.Status == OrderStatus.Ready ? o.PickupToken : null);

    private static StaffOrderDto ToStaffDto(Order o) => new(
        o.Id, o.Number, o.Status, o.Total, o.Customer.Name, ToSlotDto(o.BreakSlot), ToItemDtos(o));
}
