using System.Net;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

public class NotificationTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static async Task<OrderDto> PlaceAsync(HttpClient customer)
    {
        var response = await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]));
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        return (await response.ReadResultAsync<OrderDto>()).Data!;
    }

    private static Task<List<NotificationDto>> ListAsync(HttpClient client) =>
        client.GetDataAsync<List<NotificationDto>>("/me/notifications");

    [Fact]
    public async Task Accepted_and_ready_orders_leave_notifications_newest_first()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);

        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(10))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Cooking))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Ready))).EnsureSuccessStatusCode();

        var list = await ListAsync(customer);
        // Paid and Cooking are shown by the open app only, like push.
        Assert.Equal(
            [$"Замовлення №{order.Number} готове!", $"Замовлення №{order.Number} прийнято"],
            list.Select(n => n.Title));
        Assert.All(list, n => Assert.Equal(order.Id, n.OrderId));
        Assert.All(list, n => Assert.False(n.IsRead));
    }

    [Fact]
    public async Task Reading_marks_everything_read()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);
        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(5))).EnsureSuccessStatusCode();

        (await customer.PostAsync("/me/notifications/read", null)).EnsureSuccessStatusCode();

        Assert.All(await ListAsync(customer), n => Assert.True(n.IsRead));
    }

    [Fact]
    public async Task Own_cancellation_leaves_no_notification()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var order = await PlaceAsync(customer);

        (await customer.PostAsync($"/orders/{order.Id}/cancel", null)).EnsureSuccessStatusCode();

        Assert.Empty(await ListAsync(customer));
    }

    [Fact]
    public async Task Customers_see_only_their_own()
    {
        var (owner, _) = await api.LoginCustomerAsync();
        var (stranger, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(owner);
        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(5))).EnsureSuccessStatusCode();

        Assert.Single(await ListAsync(owner));
        Assert.Empty(await ListAsync(stranger));
    }

    [Fact]
    public async Task Deleting_the_account_deletes_its_notifications()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var id = (await customer.GetDataAsync<MeDto>("/me")).Id;
        var cook = await api.LoginCookAsync();
        var order = await PlaceAsync(customer);
        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(5))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Cooking))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Ready))).EnsureSuccessStatusCode();

        await api.WithDbAsync(async db =>
        {
            var o = await db.Orders.FindAsync(order.Id);
            o!.Status = OrderStatus.PickedUp; // finished, so deletion is allowed
            await db.SaveChangesAsync();
            return 0;
        });
        (await customer.DeleteAsync("/me")).EnsureSuccessStatusCode();

        var left = await api.WithDbAsync(db =>
            Task.FromResult(db.Notifications.Count(n => n.UserId == id)));
        Assert.Equal(0, left);
    }
}
