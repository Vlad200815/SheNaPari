using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Orders;

/// «How was it?» after pickup: the rating itself, the home card and the one
/// push that asks for it.
public class RatingService(AppDbContext db, CampusClock clock, OrderNotifier notifier, IOptions<OrderOptions> options)
{
    public const int MaxComment = 500;

    /// Tags offered for 4–5 stars and for 1–3; the apps show the text.
    public static readonly string[] PositiveTags = ["tasty", "fast", "hot", "big_portion", "no_queue"];
    public static readonly string[] NegativeTags = ["cold", "slow", "small_portion", "wrong_order", "not_tasty"];

    private OrderOptions Options => options.Value;

    /// Rates the order, or changes the rating, while the window is open.
    public async Task<Result<OrderRatingDto>> RateAsync(Guid customerId, Guid orderId, RateOrderDto dto)
    {
        if (dto.Stars is < 1 or > 5) return RatingErrors.InvalidStars;
        var tags = (dto.Tags ?? []).Distinct().ToList();
        var allowed = dto.Stars >= 4 ? PositiveTags : NegativeTags;
        if (tags.Any(t => !allowed.Contains(t))) return RatingErrors.InvalidTag;
        var comment = string.IsNullOrWhiteSpace(dto.Comment) ? null : dto.Comment.Trim();
        if (comment is { Length: > MaxComment }) return RatingErrors.CommentTooLong;

        var order = await db.Orders.Include(o => o.Rating)
            .FirstOrDefaultAsync(o => o.Id == orderId && o.CustomerId == customerId);
        if (order is null) return OrderErrors.NotFound;
        if (order.Status != OrderStatus.PickedUp || order.PickedUpAt is null) return RatingErrors.NotPickedUp;
        var now = clock.UtcNow;
        if (order.PickedUpAt.Value.AddDays(Options.RatingWindowDays) <= now) return RatingErrors.WindowClosed;

        var rating = order.Rating ??= new OrderRating { OrderId = order.Id, CreatedAt = now };
        rating.Stars = dto.Stars;
        rating.Tags = string.Join(',', tags);
        rating.Comment = comment;
        rating.UpdatedAt = now;
        await db.SaveChangesAsync();
        return ToDto(rating)!;
    }

    /// «Не зараз» on the home card.
    public async Task<Result<object?>> DismissAsync(Guid customerId, Guid orderId)
    {
        var order = await db.Orders.FirstOrDefaultAsync(o => o.Id == orderId && o.CustomerId == customerId);
        if (order is null) return OrderErrors.NotFound;
        order.RatingDismissedAt ??= clock.UtcNow;
        await db.SaveChangesAsync();
        return Result.Ok();
    }

    /// The home card: the latest picked-up order, once there was time to eat
    /// it, unless it is rated, dismissed, too old, or a newer order exists.
    /// A list of none or one, so «nothing to ask» is not an error.
    public async Task<List<RatingPromptDto>> GetPromptAsync(Guid customerId)
    {
        var now = clock.UtcNow;
        var latest = await db.Orders
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt)
            .Include(o => o.Items)
            .Include(o => o.Rating)
            .FirstOrDefaultAsync();
        if (latest is not { Status: OrderStatus.PickedUp, PickedUpAt: { } at, Rating: null, RatingDismissedAt: null }
            || at > now.AddMinutes(-Options.RatingAskAfterMinutes)
            || at <= now.AddHours(-Options.RatingCardHours))
            return [];
        var items = latest.Items.Select(i => Lang.Pick(i.NameSnapshot, i.NameEnSnapshot)).ToList();
        return [new RatingPromptDto(latest.Id, latest.Number, items, at)];
    }

    /// The timer's job: one «how was it?» push per order, [after] the pickup.
    /// Orders older than the home card's life are skipped (no late pushes
    /// after downtime). Returns how many were asked.
    public async Task<int> AskDueAsync(TimeSpan after)
    {
        var now = clock.UtcNow;
        var due = now - after;
        var oldest = now.AddHours(-Options.RatingCardHours);
        var orders = await db.Orders
            .Where(o => o.Status == OrderStatus.PickedUp && o.RatingAskedAt == null && o.Rating == null
                && o.PickedUpAt != null && o.PickedUpAt <= due && o.PickedUpAt > oldest)
            .ToListAsync();
        foreach (var order in orders) order.RatingAskedAt = now;
        await db.SaveChangesAsync();
        foreach (var order in orders) await notifier.RatingRequestedAsync(order);
        return orders.Count;
    }

    public static OrderRatingDto? ToDto(OrderRating? r) => r is null
        ? null
        : new(r.Stars, r.Tags.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(), r.Comment, r.UpdatedAt);
}
