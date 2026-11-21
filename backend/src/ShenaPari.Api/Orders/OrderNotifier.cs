using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.SignalR;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Push;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Orders;

/// Everything the server tells apps about orders goes through here:
///  - SignalR: instant updates for apps that are open
///  - push notifications: for the client whose app is closed
///  - a stored notification: the list under the bell in the app
public class OrderNotifier(IHubContext<OrdersHub> hub, PushService push, CampusClock clock, AppDbContext db)
{
    /// A new paid order appeared → the kitchen screen.
    public Task OrderCreatedAsync(StaffOrderDto order) =>
        hub.Clients.Group(OrdersHub.StaffGroup).SendAsync("OrderCreated", order);

    /// Status changed → the order's owner and the kitchen screen; plus a push for the owner
    /// when it is something they are waiting for.
    public async Task StatusChangedAsync(Order order)
    {
        var message = BuildPush(order);
        // Saved before the SignalR event: an app that reloads on the event
        // already finds the new notification under the bell.
        if (message is not null)
        {
            db.Notifications.Add(new Notification
            {
                UserId = order.CustomerId,
                OrderId = order.Id,
                Title = message.Title,
                Body = message.Body,
                CreatedAt = clock.UtcNow,
            });
            await db.SaveChangesAsync();
        }

        await hub.Clients
            .Groups(OrdersHub.UserGroup(order.CustomerId), OrdersHub.StaffGroup)
            .SendAsync("OrderStatusChanged",
                new OrderStatusChangedEvent(order.Id, order.Number, order.Status, order.EstimatedReadyAt));

        // The list under the bell always gets it; the push only if wanted.
        if (message is not null && await WantsPushAsync(order.CustomerId))
            await push.SendToUserAsync(order.CustomerId, message);
    }

    /// «Як вам №36?» some time after pickup: a line under the bell and, if
    /// wanted, a push that opens the rating sheet.
    public async Task RatingRequestedAsync(Order order)
    {
        var en = order.Language == "en";
        var title = en ? $"How was order #{order.Number}?" : $"Як вам №{order.Number}?";
        var body = en ? "Rate it in one tap: the kitchen reads every review" : "Оцініть одним дотиком: кухня читає кожен відгук";
        db.Notifications.Add(new Notification
        {
            UserId = order.CustomerId,
            OrderId = order.Id,
            Title = title,
            Body = body,
            CreatedAt = clock.UtcNow,
        });
        await db.SaveChangesAsync();
        if (await WantsPushAsync(order.CustomerId))
            await push.SendToUserAsync(order.CustomerId, new PushMessage(title, body, new Dictionary<string, string>
            {
                ["type"] = "rate_order",
                ["orderId"] = order.Id.ToString(),
            }));
    }

    /// Kitchen paused or resumed taking orders → everyone connected.
    public Task CanteenChangedAsync(CanteenDto canteen) =>
        hub.Clients.All.SendAsync("CanteenChanged", canteen);

    /// A dish ran out / came back (stop list) or the admin edited the menu →
    /// everyone connected reloads it. [dishId] is null for category changes.
    public Task MenuChangedAsync(int? dishId) =>
        hub.Clients.All.SendAsync("MenuChanged", new MenuChangedEvent(dishId));

    private async Task<bool> WantsPushAsync(Guid customerId) =>
        await db.Customers
            .Where(c => c.Id == customerId)
            .Select(c => c.OrderPushEnabled)
            .FirstOrDefaultAsync();

    private PushMessage? BuildPush(Order order)
    {
        var last = order.StatusChanges.OrderBy(c => c.At).ThenBy(c => c.Id).LastOrDefault();
        var en = order.Language == "en";
        var n = order.Number;
        (string Title, string Body)? text = order.Status switch
        {
            OrderStatus.Accepted => (
                en ? $"Order #{n} accepted" : $"Замовлення №{n} прийнято",
                order.EstimatedReadyAt is { } eta
                    ? en
                        ? $"It will be ready at about {clock.ToLocalTime(eta):HH:mm}"
                        : $"Буде готове приблизно о {clock.ToLocalTime(eta):HH:mm}"
                    : en ? "The kitchen is already on it" : "Кухня вже працює над ним"),
            OrderStatus.Ready => (
                en ? $"Order #{n} is ready!" : $"Замовлення №{n} готове!",
                en ? "Show the QR code at the counter" : "Покажіть QR-код на видачі"),
            // The client doesn't need a push about their own cancellation.
            // A reason typed by the kitchen is shown as typed.
            OrderStatus.Cancelled when last?.ChangedByUserId != order.CustomerId => (
                en ? $"Order #{n} cancelled" : $"Замовлення №{n} скасовано",
                (last?.Reason ?? (en ? "Cancelled by the kitchen" : "Скасовано кухнею"))
                    + (en ? ". Money refunded" : ". Кошти повернуто")),
            OrderStatus.NotPickedUp => (
                en ? $"Order #{n} was not picked up" : $"Замовлення №{n} не забрали",
                en ? "The pick-up time is over, the order is closed" : "Час видачі минув, замовлення закрито"),
            _ => null, // Paid, Cooking, PickedUp: the open app shows them, no push needed
        };
        if (text is null) return null;

        return new PushMessage(text.Value.Title, text.Value.Body, new Dictionary<string, string>
        {
            ["type"] = "order_status",
            ["orderId"] = order.Id.ToString(),
            ["status"] = order.Status.ToString(),
        });
    }
}
