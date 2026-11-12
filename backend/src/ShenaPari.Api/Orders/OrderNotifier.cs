using Microsoft.AspNetCore.SignalR;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Orders;

/// Everything the server tells apps in real time goes through here
/// (SignalR now; push notifications will be added in the same place).
public class OrderNotifier(IHubContext<OrdersHub> hub)
{
    /// A new paid order appeared → the kitchen screen.
    public Task OrderCreatedAsync(StaffOrderDto order) =>
        hub.Clients.Group(OrdersHub.StaffGroup).SendAsync("OrderCreated", order);

    /// Status changed → the order's owner and the kitchen screen.
    public Task StatusChangedAsync(Order order) =>
        hub.Clients
            .Groups(OrdersHub.UserGroup(order.CustomerId), OrdersHub.StaffGroup)
            .SendAsync("OrderStatusChanged",
                new OrderStatusChangedEvent(order.Id, order.Number, order.Status, order.EstimatedReadyAt));

    /// Kitchen paused or resumed taking orders → everyone connected.
    public Task CanteenChangedAsync(CanteenDto canteen) =>
        hub.Clients.All.SendAsync("CanteenChanged", canteen);
}
