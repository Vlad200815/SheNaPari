using Microsoft.AspNetCore.SignalR;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Push;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Orders;

/// Everything the server tells apps about orders goes through here:
///  - SignalR: instant updates for apps that are open
///  - push notifications: for the client whose app is closed
public class OrderNotifier(IHubContext<OrdersHub> hub, PushService push, CampusClock clock)
{
    /// A new paid order appeared → the kitchen screen.
    public Task OrderCreatedAsync(StaffOrderDto order) =>
        hub.Clients.Group(OrdersHub.StaffGroup).SendAsync("OrderCreated", order);

    /// Status changed → the order's owner and the kitchen screen; plus a push for the owner
    /// when it is something they are waiting for.
    public async Task StatusChangedAsync(Order order)
    {
        await hub.Clients
            .Groups(OrdersHub.UserGroup(order.CustomerId), OrdersHub.StaffGroup)
            .SendAsync("OrderStatusChanged",
                new OrderStatusChangedEvent(order.Id, order.Number, order.Status, order.EstimatedReadyAt));

        if (BuildPush(order) is { } message)
            await push.SendToUserAsync(order.CustomerId, message);
    }

    /// Kitchen paused or resumed taking orders → everyone connected.
    public Task CanteenChangedAsync(CanteenDto canteen) =>
        hub.Clients.All.SendAsync("CanteenChanged", canteen);

    private PushMessage? BuildPush(Order order)
    {
        var last = order.StatusChanges.OrderBy(c => c.At).ThenBy(c => c.Id).LastOrDefault();
        (string Title, string Body)? text = order.Status switch
        {
            OrderStatus.Accepted => (
                $"Замовлення №{order.Number} прийнято",
                order.EstimatedReadyAt is { } eta
                    ? $"Буде готове приблизно о {clock.ToLocalTime(eta):HH:mm}"
                    : "Кухня вже працює над ним"),
            OrderStatus.Ready => (
                $"Замовлення №{order.Number} готове!",
                "Покажіть QR-код на видачі"),
            // The client doesn't need a push about their own cancellation.
            OrderStatus.Cancelled when last?.ChangedByUserId != order.CustomerId => (
                $"Замовлення №{order.Number} скасовано",
                $"{last?.Reason ?? "Скасовано кухнею"}. Кошти повернуто"),
            OrderStatus.NotPickedUp => (
                $"Замовлення №{order.Number} не забрали",
                "Час видачі минув, замовлення закрито"),
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
