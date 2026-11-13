using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Tests;

public class OrderFlowTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static CreateOrderDto Order(params (int DishId, int Quantity)[] items) =>
        new(null, PaymentProvider.GooglePay, items.Select(i => new CreateOrderItemDto(i.DishId, i.Quantity)).ToList());

    private static async Task<OrderDto> PlaceAsync(HttpClient customer, CreateOrderDto? dto = null)
    {
        var response = await customer.PostJsonAsync("/orders", dto ?? Order((1, 1)));
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        return (await response.ReadResultAsync<OrderDto>()).Data!;
    }

    private static Task<HttpResponseMessage> SetStatusAsync(HttpClient cook, Guid id, OrderStatus status, string? reason = null) =>
        cook.PatchJsonAsync($"/staff/orders/{id}/status", new UpdateStatusDto(status, reason));

    private static Task<HttpResponseMessage> AcceptAsync(HttpClient cook, Guid id, int minutes = 10) =>
        cook.PostJsonAsync($"/staff/orders/{id}/accept", new AcceptOrderDto(minutes));

    [Fact]
    public async Task Order_is_created_paid_and_priced_by_the_server()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var prices = await api.WithDbAsync(db => db.Dishes.Where(d => d.Id == 1 || d.Id == 4).ToDictionaryAsync(d => d.Id, d => d.Price));

        // the same dish twice in the request is merged into one line
        var order = await PlaceAsync(customer, Order((1, 2), (4, 1), (1, 1)));

        Assert.Equal(OrderStatus.Paid, order.Status);
        Assert.Equal(PaymentProvider.GooglePay, order.PaymentProvider);
        Assert.Null(order.BreakSlot); // "as soon as possible"
        Assert.Equal(2, order.Items.Count);
        Assert.Equal(3, order.Items.Single(i => i.DishId == 1).Quantity);
        Assert.Equal(prices[1] * 3 + prices[4], order.Total);
        Assert.Null(order.PickupToken);
    }

    [Fact]
    public async Task Full_lifecycle_from_paid_to_picked_up()
    {
        var (customer, _) = await api.LoginCustomerAsync(name: "Оля");
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);

        var board = await cook.GetDataAsync<List<StaffOrderDto>>("/staff/orders");
        Assert.Contains(board, o => o.Id == order.Id && o.CustomerName == "Оля");

        var accepted = (await (await AcceptAsync(cook, order.Id, 15)).ReadResultAsync<StaffOrderDto>()).Data!;
        Assert.Equal(OrderStatus.Accepted, accepted.Status);
        Assert.InRange(accepted.EstimatedReadyAt!.Value - DateTimeOffset.UtcNow, TimeSpan.FromMinutes(14), TimeSpan.FromMinutes(15.1));

        Assert.Equal(HttpStatusCode.OK, (await SetStatusAsync(cook, order.Id, OrderStatus.Cooking)).StatusCode);
        Assert.Null((await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).PickupToken); // no QR yet
        Assert.Equal(HttpStatusCode.OK, (await SetStatusAsync(cook, order.Id, OrderStatus.Ready)).StatusCode);

        var ready = await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}");
        Assert.NotNull(ready.PickupToken); // the QR appears only when the food is ready

        var pickup = await cook.PostJsonAsync("/staff/orders/pickup", new PickupDto(ready.PickupToken!.Value));
        var again = await cook.PostJsonAsync("/staff/orders/pickup", new PickupDto(ready.PickupToken.Value));
        Assert.Equal(HttpStatusCode.OK, pickup.StatusCode);
        Assert.Equal(["order.already_picked_up"], (await again.ReadResultAsync<object>()).Errors);

        var done = await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}");
        Assert.Equal(
            [OrderStatus.Paid, OrderStatus.Accepted, OrderStatus.Cooking, OrderStatus.Ready, OrderStatus.PickedUp],
            done.History.Select(h => h.Status));
        Assert.DoesNotContain(await cook.GetDataAsync<List<StaffOrderDto>>("/staff/orders"), o => o.Id == order.Id);
    }

    [Fact]
    public async Task Steps_cannot_be_skipped()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);

        var skip = await SetStatusAsync(cook, order.Id, OrderStatus.Ready);
        var acceptWithoutEta = await SetStatusAsync(cook, order.Id, OrderStatus.Accepted);
        var badEta = await AcceptAsync(cook, order.Id, minutes: 7);

        Assert.Equal(HttpStatusCode.Conflict, skip.StatusCode);
        Assert.Equal(["order.invalid_transition"], (await skip.ReadResultAsync<object>()).Errors);
        Assert.Equal(["order.eta_required"], (await acceptWithoutEta.ReadResultAsync<object>()).Errors);
        Assert.Equal(["order.invalid_eta"], (await badEta.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Customer_can_cancel_before_cooking_and_gets_a_refund()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var order = await PlaceAsync(customer);

        var cancel = await customer.PostAsync($"/orders/{order.Id}/cancel", null);

        Assert.Equal(OrderStatus.Cancelled, (await cancel.ReadResultAsync<OrderDto>()).Data!.Status);
        var payment = await api.WithDbAsync(db => db.Payments.SingleAsync(p => p.OrderId == order.Id));
        Assert.Equal(PaymentStatus.Refunded, payment.Status);
    }

    [Fact]
    public async Task Nobody_can_cancel_once_cooking_has_started()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);
        await AcceptAsync(cook, order.Id);
        await SetStatusAsync(cook, order.Id, OrderStatus.Cooking);

        var byCustomer = await customer.PostAsync($"/orders/{order.Id}/cancel", null);
        var byCook = await SetStatusAsync(cook, order.Id, OrderStatus.Cancelled);

        Assert.Equal(["order.cannot_cancel"], (await byCustomer.ReadResultAsync<object>()).Errors);
        Assert.Equal(["order.invalid_transition"], (await byCook.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Kitchen_cancellation_keeps_the_reason_in_history()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);

        await SetStatusAsync(cook, order.Id, OrderStatus.Cancelled, "Закінчились продукти");

        var history = (await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).History;
        Assert.Equal((OrderStatus.Cancelled, "Закінчились продукти"), (history[^1].Status, history[^1].Reason));
    }

    [Fact]
    public async Task Customer_sees_only_their_own_orders()
    {
        var (owner, _) = await api.LoginCustomerAsync();
        var (stranger, _) = await api.LoginCustomerAsync();
        var order = await PlaceAsync(owner);

        Assert.Equal(HttpStatusCode.NotFound, (await stranger.GetAsync($"/orders/{order.Id}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await stranger.PostAsync($"/orders/{order.Id}/cancel", null)).StatusCode);
        Assert.Empty(await stranger.GetDataAsync<List<OrderDto>>("/orders/my"));
    }

    [Theory]
    [InlineData(0, "order.empty")]
    [InlineData(21, "order.invalid_quantity")]
    public async Task Bad_orders_are_rejected(int quantity, string expectedError)
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var dto = quantity == 0 ? Order() : Order((1, quantity));

        var response = await customer.PostJsonAsync("/orders", dto);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal([expectedError], (await response.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Order_needs_a_payment_method_and_existing_dishes()
    {
        var (customer, _) = await api.LoginCustomerAsync();

        var noPayment = await customer.PostJsonAsync("/orders", new CreateOrderDto(null, null, [new(1, 1)]));
        var unknownDish = await customer.PostJsonAsync("/orders", Order((9999, 1)));

        Assert.Equal(["order.payment_required"], (await noPayment.ReadResultAsync<object>()).Errors);
        Assert.Equal(["order.dish_unavailable"], (await unknownDish.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Ready_order_nobody_picked_up_is_closed_by_the_timer()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);
        await AcceptAsync(cook, order.Id);
        await SetStatusAsync(cook, order.Id, OrderStatus.Cooking);
        await SetStatusAsync(cook, order.Id, OrderStatus.Ready);

        // 30 minutes have not passed: nothing happens
        await api.WithServiceAsync<OrderService, int>(s => s.ExpireNotPickedUpAsync(TimeSpan.FromMinutes(30)));
        Assert.Equal(OrderStatus.Ready, (await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}")).Status);

        // what the timer does once the limit is over
        await api.WithServiceAsync<OrderService, int>(s => s.ExpireNotPickedUpAsync(TimeSpan.Zero));
        var closed = await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}");
        Assert.Equal(OrderStatus.NotPickedUp, closed.Status);
        Assert.Null(closed.PickupToken);
    }

    [Fact]
    public async Task Push_is_sent_when_accepted_and_ready_but_not_for_own_cancellation()
    {
        var device = $"device-{Guid.NewGuid():N}";
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        await customer.PutJsonAsync("/me/push-token", new PushTokenDto(device));

        var first = await PlaceAsync(customer);
        await AcceptAsync(cook, first.Id);
        await SetStatusAsync(cook, first.Id, OrderStatus.Cooking);
        await SetStatusAsync(cook, first.Id, OrderStatus.Ready);
        var second = await PlaceAsync(customer);
        await customer.PostAsync($"/orders/{second.Id}/cancel", null);

        Assert.Equal(
            [$"Замовлення №{first.Number} прийнято", $"Замовлення №{first.Number} готове!"],
            api.Push.TitlesFor(device));
    }

    [Fact]
    public async Task After_logout_the_device_gets_no_more_pushes()
    {
        var device = $"device-{Guid.NewGuid():N}";
        var (customer, auth) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        await customer.PutJsonAsync("/me/push-token", new PushTokenDto(device));
        var order = await PlaceAsync(customer);

        await customer.PostJsonAsync("/auth/logout", new RefreshDto(auth.RefreshToken));
        await AcceptAsync(cook, order.Id);

        Assert.Empty(api.Push.TitlesFor(device));
    }
}

/// These tests flip switches that affect every order, so they get a server of their own.
public class KitchenSwitchTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly CreateOrderDto OneBorscht =
        new(null, PaymentProvider.ApplePay, [new CreateOrderItemDto(10, 1)]);

    [Fact]
    public async Task Paused_kitchen_takes_no_orders_until_resumed()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();

        var byCustomer = await customer.PutJsonAsync("/staff/canteen/accepting", new SetAcceptingDto(false));
        Assert.Equal(HttpStatusCode.Forbidden, byCustomer.StatusCode);

        await cook.PutJsonAsync("/staff/canteen/accepting", new SetAcceptingDto(false));
        Assert.False((await customer.GetDataAsync<CanteenDto>("/canteen")).IsAcceptingOrders);
        var paused = await customer.PostJsonAsync("/orders", OneBorscht);
        Assert.Equal(HttpStatusCode.Conflict, paused.StatusCode);
        Assert.Equal(["order.canteen_paused"], (await paused.ReadResultAsync<object>()).Errors);

        await cook.PutJsonAsync("/staff/canteen/accepting", new SetAcceptingDto(true));
        Assert.Equal(HttpStatusCode.Created, (await customer.PostJsonAsync("/orders", OneBorscht)).StatusCode);
    }

    [Fact]
    public async Task Dish_on_the_stop_list_disappears_for_customers()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        const int dishId = 11;

        await cook.PatchJsonAsync($"/staff/dishes/{dishId}/availability", new SetAvailabilityDto(false));

        Assert.DoesNotContain(await customer.GetDataAsync<List<DishDto>>("/dishes"), d => d.Id == dishId);
        Assert.Equal(HttpStatusCode.NotFound, (await customer.GetAsync($"/dishes/{dishId}")).StatusCode);
        var order = await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new(dishId, 1)]));
        Assert.Equal(["order.dish_unavailable"], (await order.ReadResultAsync<object>()).Errors);
        Assert.Contains(await cook.GetDataAsync<List<StaffDishDto>>("/staff/dishes"), d => d.Id == dishId && !d.IsAvailable);
    }
}
