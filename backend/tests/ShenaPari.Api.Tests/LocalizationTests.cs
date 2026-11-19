using System.Net;
using System.Reflection;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

/// The app sends Accept-Language (uk or en); the server answers in it.
public class LocalizationTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static HttpClient InEnglish(HttpClient client)
    {
        client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("en");
        return client;
    }

    [Fact]
    public async Task Errors_come_in_the_requested_language()
    {
        var uk = await api.CreateClient().GetAsync("/legal/cookies");
        var en = await InEnglish(api.CreateClient()).GetAsync("/legal/cookies");

        Assert.Equal("Документ не знайдено", (await uk.ReadResultAsync<object>()).Message);
        var english = await en.ReadResultAsync<object>();
        Assert.Equal("Document not found", english.Message);
        Assert.Equal(["legal.not_found"], english.Errors);
    }

    [Fact]
    public async Task An_unsupported_language_gets_Ukrainian()
    {
        var client = api.CreateClient();
        client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("de");

        var response = await client.GetAsync("/legal/cookies");

        Assert.Equal("Документ не знайдено", (await response.ReadResultAsync<object>()).Message);
    }

    [Fact]
    public async Task Errors_written_outside_controllers_are_translated_too()
    {
        // 401 is written by the JWT challenge, not by a controller.
        var response = await InEnglish(api.CreateClient()).GetAsync("/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.Equal("Please sign in", (await response.ReadResultAsync<object>()).Message);
    }

    [Fact]
    public void Every_error_has_an_English_text()
    {
        var errors = typeof(Error).Assembly.GetTypes()
            .SelectMany(t => t.GetFields(BindingFlags.Public | BindingFlags.Static))
            .Where(f => f.FieldType == typeof(Error))
            .Select(f => (Error)f.GetValue(null)!)
            .ToList();

        Assert.NotEmpty(errors);
        Assert.All(errors, e => Assert.True(
            ErrorTexts.English.ContainsKey(e.Code), $"no English text for {e.Code}"));
        Assert.All(ErrorTexts.English.Values,
            text => Assert.DoesNotMatch("[Ѐ-ӿ]", text));
    }

    [Theory]
    [InlineData("terms", "## 1. Acceptance of the terms")]
    [InlineData("privacy", "## 1. General provisions")]
    [InlineData("refund", "## 1. General provisions")]
    public async Task Documents_come_in_English(string type, string firstHeading)
    {
        var client = InEnglish(api.CreateClient());

        var english = await client.GetDataAsync<LegalDocumentDto>($"/legal/{type}");
        var ukrainian = await api.CreateClient().GetDataAsync<LegalDocumentDto>($"/legal/{type}");

        Assert.StartsWith(firstHeading, english.Content);
        Assert.NotEqual(ukrainian.Version, english.Version);
    }

    [Fact]
    public async Task Notifications_use_the_language_the_order_was_placed_in()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        InEnglish(customer);
        var cook = await api.LoginCookAsync(); // the kitchen's own language does not matter
        var response = await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]));
        var order = (await response.ReadResultAsync<OrderDto>()).Data!;

        (await cook.PostJsonAsync($"/staff/orders/{order.Id}/accept", new AcceptOrderDto(10))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Cooking))).EnsureSuccessStatusCode();
        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Ready))).EnsureSuccessStatusCode();

        var list = await customer.GetDataAsync<List<NotificationDto>>("/me/notifications");
        Assert.Equal(
            [$"Order #{order.Number} is ready!", $"Order #{order.Number} accepted"],
            list.Select(n => n.Title));
        Assert.Equal("Show the QR code at the counter", list[0].Body);
    }

    [Fact]
    public async Task A_kitchen_cancellation_without_a_reason_is_explained_in_English()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        InEnglish(customer);
        var cook = await api.LoginCookAsync();
        var response = await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new CreateOrderItemDto(1, 1)]));
        var order = (await response.ReadResultAsync<OrderDto>()).Data!;

        (await cook.PatchJsonAsync($"/staff/orders/{order.Id}/status", new UpdateStatusDto(OrderStatus.Cancelled))).EnsureSuccessStatusCode();

        var notification = Assert.Single(await customer.GetDataAsync<List<NotificationDto>>("/me/notifications"));
        Assert.Equal($"Order #{order.Number} cancelled", notification.Title);
        Assert.Equal("Cancelled by the kitchen. Money refunded", notification.Body);
        // No made-up reason in the order's history: the app explains it itself.
        var details = await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}");
        Assert.Null(details.History[^1].Reason);
    }

    [Fact]
    public async Task Category_names_come_in_the_requested_language()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        InEnglish(customer);

        var categories = await customer.GetDataAsync<List<CategoryDto>>("/categories");

        // Take(6): another test in this class adds its own category.
        Assert.Equal(["Burgers", "Hot dogs", "Baguettes", "Hot meals", "Pastries", "Drinks"], categories.Take(6).Select(c => c.Name));
    }

    [Fact]
    public async Task A_category_without_an_English_name_shows_the_Ukrainian_one()
    {
        var admin = await api.LoginSuperAdminAsync();
        var created = await (await admin.PostJsonAsync("/admin/categories", new SaveCategoryDto("Салати", 99, NameEn: " ")))
            .ReadResultAsync<AdminCategoryDto>();
        Assert.Null(created.Data!.NameEn);
        var (customer, _) = await api.LoginCustomerAsync();
        InEnglish(customer);

        var categories = await customer.GetDataAsync<List<CategoryDto>>("/categories");

        Assert.Equal("Салати", categories[^1].Name);
    }
}
