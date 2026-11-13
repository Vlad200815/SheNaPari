using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

public class ScheduleTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private const int MainId = 1, ShortenedId = 2, HourlyTestId = 3;

    [Fact]
    public async Task Two_university_schedules_are_seeded_and_the_shortened_one_is_active()
    {
        var admin = await api.LoginSuperAdminAsync();

        var schedules = await admin.GetDataAsync<List<BellScheduleDto>>("/admin/schedules");

        var main = schedules.Single(s => s.Id == MainId);
        var shortened = schedules.Single(s => s.Id == ShortenedId);
        Assert.Equal(("Основний", 7), (main.Name, main.Breaks.Count));
        Assert.Equal(("Скорочений", 7), (shortened.Name, shortened.Breaks.Count));
        // the long break: after the 3rd class in the main schedule, after the 4th in the shortened one
        Assert.Contains(main.Breaks, b => b.Start == new TimeOnly(12, 50) && b.End == new TimeOnly(13, 20));
        Assert.Contains(shortened.Breaks, b => b.Start == new TimeOnly(13, 0) && b.End == new TimeOnly(13, 30));
        Assert.True(schedules.Count(s => s.IsActive) == 1);
    }

    [Fact]
    public async Task Switching_the_schedule_rebuilds_free_slots_but_keeps_slots_with_orders()
    {
        var admin = await api.LoginSuperAdminAsync();
        var (customer, _) = await api.LoginCustomerAsync();

        // the hourly schedule always has an upcoming break, whatever time the test runs at
        await admin.PostAsync($"/admin/schedules/{HourlyTestId}/activate", null);
        var next = await customer.GetDataAsync<BreakSlotDto>("/breaks/next");
        Assert.Equal(0, next.StartsAt.Minute);

        var order = (await (await customer.PostJsonAsync("/orders",
            new CreateOrderDto(next.Id, PaymentProvider.GooglePay, [new(1, 1)]))).ReadResultAsync<OrderDto>()).Data!;
        Assert.Equal(next.Id, order.BreakSlot!.Id);

        await admin.PostAsync($"/admin/schedules/{MainId}/activate", null);

        var now = DateTimeOffset.UtcNow;
        var slots = await api.WithDbAsync(db => db.BreakSlots.Where(b => b.StartsAt > now).ToListAsync());
        Assert.Contains(slots, s => s.Id == next.Id);                       // the ordered slot survived
        Assert.All(slots.Where(s => s.Id != next.Id),                        // the rest follow the main schedule
            s => Assert.Contains(s.StartsAt.Minute, new[] { 50, 20, 40, 10 }));
        var active = (await admin.GetDataAsync<List<BellScheduleDto>>("/admin/schedules")).Single(s => s.IsActive);
        Assert.Equal(MainId, active.Id);
    }

    [Fact]
    public async Task Invalid_or_active_schedules_are_protected()
    {
        var admin = await api.LoginSuperAdminAsync();

        var overlapping = await admin.PostJsonAsync("/admin/schedules", new CreateScheduleDto("Перетин",
            [new(new TimeOnly(10, 0), new TimeOnly(10, 20)), new(new TimeOnly(10, 10), new TimeOnly(10, 30))]));
        var backwards = await admin.PostJsonAsync("/admin/schedules", new CreateScheduleDto("Навпаки",
            [new(new TimeOnly(11, 0), new TimeOnly(10, 0))]));
        var activeId = (await admin.GetDataAsync<List<BellScheduleDto>>("/admin/schedules")).Single(s => s.IsActive).Id;
        var deleteActive = await admin.DeleteAsync($"/admin/schedules/{activeId}");

        Assert.Equal(["schedule.invalid_breaks"], (await overlapping.ReadResultAsync<object>()).Errors);
        Assert.Equal(["schedule.invalid_breaks"], (await backwards.ReadResultAsync<object>()).Errors);
        Assert.Equal(["schedule.active_cannot_be_deleted"], (await deleteActive.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task A_break_that_already_started_cannot_be_chosen()
    {
        var (customer, _) = await api.LoginCustomerAsync();
        var past = await api.WithDbAsync(async db =>
        {
            var slot = new BreakSlot { StartsAt = DateTimeOffset.UtcNow.AddMinutes(-5), EndsAt = DateTimeOffset.UtcNow.AddMinutes(5) };
            db.BreakSlots.Add(slot);
            await db.SaveChangesAsync();
            return slot.Id;
        });

        var response = await customer.PostJsonAsync("/orders",
            new CreateOrderDto(past, PaymentProvider.GooglePay, [new(1, 1)]));

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
        Assert.Equal(["order.break_passed"], (await response.ReadResultAsync<object>()).Errors);
    }
}

public class MenuAdminTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task Demo_menu_has_fast_food_and_hot_dishes()
    {
        var (customer, _) = await api.LoginCustomerAsync();

        var categories = await customer.GetDataAsync<List<CategoryDto>>("/categories");
        var popular = await customer.GetDataAsync<List<DishDto>>("/dishes?popular=true");

        Assert.Equal(["Бургери", "Хот-доги", "Багети", "Гарячі страви", "Випічка", "Напої"], categories.Select(c => c.Name));
        Assert.Contains(popular, d => d.Name == "Чизбургер");
        Assert.All(popular, d => Assert.True(d.IsPopular));
    }

    [Fact]
    public async Task Price_change_does_not_rewrite_old_orders()
    {
        var admin = await api.LoginSuperAdminAsync();
        var (customer, _) = await api.LoginCustomerAsync();
        var dish = (await (await admin.PostJsonAsync("/admin/dishes",
            new SaveDishDto(1, "Тестовий бургер", null, 100m, 200, 500))).ReadResultAsync<AdminDishDto>()).Data!;
        var order = (await (await customer.PostJsonAsync("/orders",
            new CreateOrderDto(null, PaymentProvider.GooglePay, [new(dish.Id, 2)]))).ReadResultAsync<OrderDto>()).Data!;

        await admin.PutJsonAsync($"/admin/dishes/{dish.Id}", new SaveDishDto(1, "Перейменований", null, 150m, 200, 500));

        var old = await customer.GetDataAsync<OrderDto>($"/orders/{order.Id}");
        Assert.Equal(("Тестовий бургер", 100m, 200m), (old.Items[0].Name, old.Items[0].UnitPrice, old.Total));
        Assert.Equal(150m, (await customer.GetDataAsync<DishDto>($"/dishes/{dish.Id}")).Price);
    }

    [Fact]
    public async Task Ordered_dish_and_non_empty_category_cannot_be_deleted()
    {
        var admin = await api.LoginSuperAdminAsync();
        var (customer, _) = await api.LoginCustomerAsync();
        await customer.PostJsonAsync("/orders", new CreateOrderDto(null, PaymentProvider.GooglePay, [new(2, 1)]));

        var dish = await admin.DeleteAsync("/admin/dishes/2");
        var category = await admin.DeleteAsync("/admin/categories/1");

        Assert.Equal(["menu.dish_in_use"], (await dish.ReadResultAsync<object>()).Errors);
        Assert.Equal(["menu.category_not_empty"], (await category.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Dish_photo_is_uploaded_and_served()
    {
        var admin = await api.LoginSuperAdminAsync();
        var dish = (await (await admin.PostJsonAsync("/admin/dishes",
            new SaveDishDto(1, "З фото", null, 50m, 100, 100))).ReadResultAsync<AdminDishDto>()).Data!;
        byte[] png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3];

        using var form = new MultipartFormDataContent();
        var file = new ByteArrayContent(png);
        file.Headers.ContentType = new("image/png");
        form.Add(file, "file", "burger.png");
        var upload = await admin.PostAsync($"/admin/dishes/{dish.Id}/image", form);
        var imageUrl = (await upload.ReadResultAsync<AdminDishDto>()).Data!.ImageUrl!;

        try
        {
            Assert.StartsWith($"/images/dishes/{dish.Id}-", imageUrl);
            Assert.Equal(png, await api.CreateClient().GetByteArrayAsync(imageUrl));

            using var bad = new MultipartFormDataContent();
            var text = new ByteArrayContent("hello"u8.ToArray());
            text.Headers.ContentType = new("text/plain");
            bad.Add(text, "file", "note.txt");
            var rejected = await admin.PostAsync($"/admin/dishes/{dish.Id}/image", bad);
            Assert.Equal(["menu.invalid_image"], (await rejected.ReadResultAsync<object>()).Errors);
        }
        finally
        {
            await admin.DeleteAsync($"/admin/dishes/{dish.Id}"); // also removes the uploaded file
        }
    }
}
