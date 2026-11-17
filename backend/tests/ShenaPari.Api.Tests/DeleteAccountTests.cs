using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

public class DeleteAccountTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static CreateOrderDto OneDish() =>
        new(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]);

    [Fact]
    public async Task Deleting_erases_the_person_and_ends_every_session()
    {
        var phone = ApiFactory.NewPhone();
        var (customer, auth) = await api.LoginCustomerAsync(phone, name: "Влад");
        var id = (await customer.GetDataAsync<MeDto>("/me")).Id;

        var response = await customer.DeleteAsync("/me");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var refresh = await api.CreateClient().PostJsonAsync("/auth/refresh", new RefreshDto(auth.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, refresh.StatusCode);

        var stored = await api.WithDbAsync(db => db.Customers.SingleAsync(c => c.Id == id));
        Assert.Null(stored.Name);
        Assert.StartsWith("del-", stored.Phone);
        Assert.NotNull(stored.DeactivatedAt);
        var liveSessions = await api.WithDbAsync(db =>
            db.RefreshTokens.CountAsync(t => t.UserId == id && t.RevokedAt == null));
        Assert.Equal(0, liveSessions);
    }

    [Fact]
    public async Task The_same_phone_can_sign_up_again_as_a_new_account()
    {
        var phone = ApiFactory.NewPhone();
        var (customer, _) = await api.LoginCustomerAsync(phone);
        var oldId = (await customer.GetDataAsync<MeDto>("/me")).Id;
        await customer.DeleteAsync("/me");

        var (again, auth) = await api.LoginCustomerAsync(phone, name: null);

        Assert.True(auth.IsNew);
        Assert.NotEqual(oldId, (await again.GetDataAsync<MeDto>("/me")).Id);
    }

    [Fact]
    public async Task Orders_stay_for_the_canteen_without_the_person()
    {
        var (customer, _) = await api.LoginCustomerAsync(name: "Влад");
        var order = (await (await customer.PostJsonAsync("/orders", OneDish())).ReadResultAsync<OrderDto>()).Data!;
        (await customer.PostAsync($"/orders/{order.Id}/cancel", null)).EnsureSuccessStatusCode();

        Assert.Equal(HttpStatusCode.OK, (await customer.DeleteAsync("/me")).StatusCode);

        var kept = await api.WithDbAsync(db => db.Orders.Include(o => o.Customer).SingleAsync(o => o.Id == order.Id));
        Assert.Null(kept.Customer.Name);
        Assert.StartsWith("del-", kept.Customer.Phone);
    }

    [Fact]
    public async Task An_active_order_blocks_deletion()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        (await customer.PostJsonAsync("/orders", OneDish())).EnsureSuccessStatusCode();

        var response = await customer.DeleteAsync("/me");

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
        Assert.Equal(["profile.has_active_order"], (await response.ReadResultAsync<object>()).Errors);
        Assert.Equal(HttpStatusCode.OK, (await customer.GetAsync("/me")).StatusCode);
    }

    [Fact]
    public async Task Staff_cannot_delete_their_own_account()
    {
        var cook = await api.LoginCookAsync();

        var response = await cook.DeleteAsync("/me");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        Assert.Equal(["profile.staff_cannot_delete"], (await response.ReadResultAsync<object>()).Errors);
    }
}
