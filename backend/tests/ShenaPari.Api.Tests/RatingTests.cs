using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Tests;

/// Rating an order after pickup: stars, tags by the score, a comment; a push
/// some time later and a card on the home screen until it is rated.
public class RatingTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly RateOrderDto Great = new(5, ["tasty", "fast"], "Найкращий бургер у корпусі");

    /// A fresh customer with one order the kitchen has just handed over.
    private async Task<(HttpClient Customer, OrderDto Order)> PickedUpAsync(string? device = null)
    {
        var (customer, _) = await api.LoginCustomerAsync();
        if (device is not null) await customer.PutJsonAsync("/me/push-token", new PushTokenDto(device));
        var cook = await api.LoginCookAsync();
        var placed = (await (await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)])))
            .ReadResultAsync<OrderDto>()).Data!;
        await cook.PostJsonAsync($"/staff/orders/{placed.Id}/accept", new AcceptOrderDto(10));
        await cook.PatchJsonAsync($"/staff/orders/{placed.Id}/status", new UpdateStatusDto(OrderStatus.Cooking, null));
        await cook.PatchJsonAsync($"/staff/orders/{placed.Id}/status", new UpdateStatusDto(OrderStatus.Ready, null));
        var ready = await customer.GetDataAsync<OrderDto>($"/orders/{placed.Id}");
        await cook.PostJsonAsync("/staff/orders/pickup", new PickupDto(ready.PickupToken!.Value));
        return (customer, await customer.GetDataAsync<OrderDto>($"/orders/{placed.Id}"));
    }

    /// Moves the pickup [minutes] into the past (the timers count from it).
    private Task<int> PickedUpAgoAsync(Guid orderId, int minutes) => api.WithDbAsync(async db =>
    {
        var order = await db.Orders.SingleAsync(o => o.Id == orderId);
        order.PickedUpAt = DateTimeOffset.UtcNow.AddMinutes(-minutes);
        return await db.SaveChangesAsync();
    });

    [Fact]
    public async Task Picked_up_order_is_rated_and_can_be_changed()
    {
        var (customer, order) = await PickedUpAsync();
        Assert.Null(order.Rating);
        Assert.NotNull(order.RateUntil);

        var rated = await customer.PutJsonAsync($"/orders/{order.Id}/rating", Great);
        Assert.Equal(HttpStatusCode.OK, rated.StatusCode);
        var rating = (await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).Rating!;
        Assert.Equal((5, "Найкращий бургер у корпусі"), (rating.Stars, rating.Comment));
        Assert.Equal(["tasty", "fast"], rating.Tags);

        await customer.PutJsonAsync($"/orders/{order.Id}/rating", new RateOrderDto(2, ["cold"], null));
        rating = (await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).Rating!;
        Assert.Equal((2, (string?)null), (rating.Stars, rating.Comment));
        Assert.Equal(["cold"], rating.Tags);
    }

    [Fact]
    public async Task Only_your_own_picked_up_order_within_three_days()
    {
        var (customer, order) = await PickedUpAsync();
        var (stranger, _) = await api.LoginCustomerAsync();
        var active = (await (await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)])))
            .ReadResultAsync<OrderDto>()).Data!;

        var notYours = await stranger.PutJsonAsync($"/orders/{order.Id}/rating", Great);
        var notYet = await customer.PutJsonAsync($"/orders/{active.Id}/rating", Great);
        await PickedUpAgoAsync(order.Id, 3 * 24 * 60 + 1);
        var tooLate = await customer.PutJsonAsync($"/orders/{order.Id}/rating", Great);

        Assert.Equal(HttpStatusCode.NotFound, notYours.StatusCode);
        Assert.Equal(["rating.not_picked_up"], (await notYet.ReadResultAsync<object>()).Errors);
        Assert.Equal(["rating.window_closed"], (await tooLate.ReadResultAsync<object>()).Errors);
        Assert.Null((await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).RateUntil);
    }

    [Theory]
    [InlineData(0, new[] { "tasty" }, null, "rating.invalid_stars")]
    [InlineData(6, new string[0], null, "rating.invalid_stars")]
    [InlineData(5, new[] { "cold" }, null, "rating.invalid_tag")] // a complaint on a five
    [InlineData(2, new[] { "tasty" }, null, "rating.invalid_tag")] // praise on a two
    [InlineData(4, new[] { "spicy" }, null, "rating.invalid_tag")]
    [InlineData(4, new string[0], "long", "rating.comment_too_long")]
    public async Task Bad_ratings_are_refused(int stars, string[] tags, string? comment, string code)
    {
        var (customer, order) = await PickedUpAsync();
        var text = comment == "long" ? new string('a', 501) : comment;

        var response = await customer.PutJsonAsync($"/orders/{order.Id}/rating", new RateOrderDto(stars, [.. tags], text));

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal([code], (await response.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task One_push_and_a_bell_notification_once_the_time_is_up()
    {
        var device = $"device-{Guid.NewGuid():N}";
        var (customer, order) = await PickedUpAsync(device);
        var askAfter = TimeSpan.FromMinutes(30);

        await api.WithServiceAsync<RatingService, int>(s => s.AskDueAsync(askAfter));
        Assert.DoesNotContain(api.Push.TitlesFor(device), t => t.StartsWith("Як вам"));

        await PickedUpAgoAsync(order.Id, 31);
        await api.WithServiceAsync<RatingService, int>(s => s.AskDueAsync(askAfter));
        await api.WithServiceAsync<RatingService, int>(s => s.AskDueAsync(askAfter)); // the next tick

        Assert.Single(api.Push.TitlesFor(device), $"Як вам №{order.Number}?");
        var message = api.Push.Sent.Last(s => s.DeviceToken == device).Message;
        Assert.Equal(("rate_order", order.Id.ToString()), (message.Data["type"], message.Data["orderId"]));
        var bell = await customer.GetDataAsync<List<NotificationDto>>("/me/notifications");
        Assert.Contains(bell, n => n.OrderId == order.Id && n.Title == $"Як вам №{order.Number}?");
    }

    [Fact]
    public async Task Already_rated_orders_are_not_asked_about()
    {
        var device = $"device-{Guid.NewGuid():N}";
        var (customer, order) = await PickedUpAsync(device);
        await customer.PutJsonAsync($"/orders/{order.Id}/rating", Great);
        await PickedUpAgoAsync(order.Id, 31);

        await api.WithServiceAsync<RatingService, int>(s => s.AskDueAsync(TimeSpan.FromMinutes(30)));

        Assert.DoesNotContain(api.Push.TitlesFor(device), t => t.StartsWith("Як вам"));
    }

    [Fact]
    public async Task Home_card_until_rated_dismissed_or_a_new_order()
    {
        var (customer, order) = await PickedUpAsync();
        Assert.Empty(await customer.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));

        await PickedUpAgoAsync(order.Id, 31);
        var prompt = Assert.Single(await customer.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));
        Assert.Equal((order.Id, order.Number), (prompt.OrderId, prompt.Number));
        Assert.NotEmpty(prompt.Items);

        (await customer.PostAsync($"/orders/{order.Id}/rating/dismiss", null)).EnsureSuccessStatusCode();
        Assert.Empty(await customer.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));

        // a second customer: rating removes the card; so does a newer order
        var (rater, rated) = await PickedUpAsync();
        await PickedUpAgoAsync(rated.Id, 31);
        await rater.PutJsonAsync($"/orders/{rated.Id}/rating", Great);
        Assert.Empty(await rater.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));

        var (hungry, eaten) = await PickedUpAsync();
        await PickedUpAgoAsync(eaten.Id, 31);
        await hungry.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]));
        Assert.Empty(await hungry.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));
    }

    [Fact]
    public async Task Card_is_gone_a_day_after_pickup()
    {
        var (customer, order) = await PickedUpAsync();
        await PickedUpAgoAsync(order.Id, 24 * 60 + 1);

        Assert.Empty(await customer.GetDataAsync<List<RatingPromptDto>>("/orders/my/rating-prompt"));
    }
}
