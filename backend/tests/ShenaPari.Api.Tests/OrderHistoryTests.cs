using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

/// The orders tab: active orders apart, the history page by page.
public class OrderHistoryTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    /// Five finished orders over two months (newest first: #5 … #1) and one still active.
    private async Task<(HttpClient Customer, List<Guid> Finished, Guid Active)> CustomerWithHistoryAsync()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var ids = new List<Guid>();
        for (var i = 0; i < 6; i++)
        {
            var response = await customer.PostJsonAsync("/orders",
                new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]));
            ids.Add((await response.ReadResultAsync<OrderDto>()).Data!.Id);
        }

        // Made-up past: noon on 10–14 October and 1 November (Kyiv), mixed outcomes.
        (DateTimeOffset At, OrderStatus Status)[] past =
        [
            (new(2026, 10, 10, 12, 0, 0, TimeSpan.FromHours(3)), OrderStatus.PickedUp),
            (new(2026, 10, 12, 12, 0, 0, TimeSpan.FromHours(3)), OrderStatus.Cancelled),
            (new(2026, 10, 14, 12, 0, 0, TimeSpan.FromHours(3)), OrderStatus.NotPickedUp),
            (new(2026, 11, 1, 12, 0, 0, TimeSpan.FromHours(2)), OrderStatus.PickedUp),
            (new(2026, 11, 1, 13, 0, 0, TimeSpan.FromHours(2)), OrderStatus.PickedUp),
        ];
        await api.WithDbAsync(async db =>
        {
            for (var i = 0; i < past.Length; i++)
            {
                var order = await db.Orders.SingleAsync(o => o.Id == ids[i]);
                order.CreatedAt = past[i].At;
                order.Status = past[i].Status;
            }
            return await db.SaveChangesAsync();
        });
        return (customer, ids.Take(5).Reverse().ToList(), ids[5]);
    }

    [Fact]
    public async Task Active_orders_come_without_the_history()
    {
        var (customer, _, active) = await CustomerWithHistoryAsync();

        var list = await customer.GetDataAsync<List<OrderDto>>("/orders/my?active=true");

        Assert.Equal([active], list.Select(o => o.Id));
    }

    [Fact]
    public async Task History_comes_page_by_page_newest_first()
    {
        var (customer, finished, _) = await CustomerWithHistoryAsync();

        var first = await customer.GetDataAsync<OrderHistoryDto>("/orders/my/history?limit=2");
        var before = Uri.EscapeDataString(first.Items[^1].CreatedAt.ToString("O"));
        var second = await customer.GetDataAsync<OrderHistoryDto>($"/orders/my/history?limit=2&before={before}");
        before = Uri.EscapeDataString(second.Items[^1].CreatedAt.ToString("O"));
        var last = await customer.GetDataAsync<OrderHistoryDto>($"/orders/my/history?limit=2&before={before}");

        Assert.Equal(finished, first.Items.Concat(second.Items).Concat(last.Items).Select(o => o.Id));
        Assert.True(first.HasMore);
        Assert.True(second.HasMore);
        Assert.False(last.HasMore);
    }

    [Fact]
    public async Task Months_sum_up_the_whole_history_without_refunds()
    {
        var (customer, _, _) = await CustomerWithHistoryAsync();
        var price = await api.WithDbAsync(db => db.Dishes.Where(d => d.Id == 1).Select(d => d.Price).SingleAsync());

        var page = await customer.GetDataAsync<OrderHistoryDto>("/orders/my/history?limit=1");

        Assert.Equal(
            [new OrderMonthDto(2026, 11, 2, 2 * price), new OrderMonthDto(2026, 10, 3, 2 * price)],
            page.Months);
    }

    [Fact]
    public async Task History_can_show_one_outcome()
    {
        var (customer, finished, _) = await CustomerWithHistoryAsync();

        var cancelled = await customer.GetDataAsync<OrderHistoryDto>("/orders/my/history?status=Cancelled");

        Assert.Equal([finished[3]], cancelled.Items.Select(o => o.Id));
        Assert.Equal([new OrderMonthDto(2026, 10, 1, 0)], cancelled.Months);
    }

    [Fact]
    public async Task An_active_status_is_not_a_history_filter()
    {
        var (customer, _) = await api.LoginCustomerAsync();

        var response = await customer.GetAsync("/orders/my/history?status=Cooking");

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal(["order.invalid_history_filter"], (await response.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Someone_elses_orders_are_not_in_the_history()
    {
        await CustomerWithHistoryAsync();
        var (stranger, _) = await api.LoginCustomerAsync();

        var page = await stranger.GetDataAsync<OrderHistoryDto>("/orders/my/history");

        Assert.Empty(page.Items);
        Assert.Empty(page.Months);
        Assert.False(page.HasMore);
    }
}
