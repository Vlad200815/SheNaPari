using System.Net;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Tests;

public class SettingsTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task Order_push_is_on_by_default_and_can_be_switched_off()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        Assert.True((await customer.GetDataAsync<MeDto>("/me")).OrderPushEnabled);

        var response = await customer.PutJsonAsync("/me/settings", new MeSettingsDto(false));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.False((await response.ReadResultAsync<MeDto>()).Data!.OrderPushEnabled);
        Assert.False((await customer.GetDataAsync<MeDto>("/me")).OrderPushEnabled);
    }

    [Fact]
    public async Task Push_off_still_keeps_the_notification_list()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var cook = await api.LoginCookAsync();
        await customer.PutJsonAsync("/me/settings", new MeSettingsDto(false));
        var order = (await (await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, Entities.PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)])))
            .ReadResultAsync<OrderDto>()).Data!;

        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(5))).EnsureSuccessStatusCode();

        Assert.Single(await customer.GetDataAsync<List<NotificationDto>>("/me/notifications"));
    }

    [Fact]
    public async Task Staff_have_no_order_push_setting()
    {
        var cook = await api.LoginCookAsync();

        Assert.Null((await cook.GetDataAsync<MeDto>("/me")).OrderPushEnabled);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await cook.PutJsonAsync("/me/settings", new MeSettingsDto(false))).StatusCode);
    }
}
