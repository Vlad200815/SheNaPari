using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Menu;

namespace ShenaPari.Api.Data;

/// Fills an empty database with a demo menu, creates break slots for the coming days
/// and creates the staff accounts listed in configuration. Safe to run on every startup.
public static class DbSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var clock = scope.ServiceProvider.GetRequiredService<CampusClock>();
        var schedule = scope.ServiceProvider.GetRequiredService<IOptions<BreakScheduleOptions>>().Value;
        var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();
        var passwords = scope.ServiceProvider.GetRequiredService<PasswordService>();

        await db.Database.MigrateAsync(); // creates/updates the SQLite file automatically

        if (!await db.Categories.AnyAsync())
        {
            db.Categories.AddRange(DemoMenu());
            await db.SaveChangesAsync();
        }

        await EnsureBreakSlotsAsync(db, clock, schedule);
        await EnsureEmployeesAsync(db, clock, passwords,
            config.GetSection("Seed:Employees").Get<List<SeedEmployee>>() ?? []);
    }

    private static async Task EnsureBreakSlotsAsync(
        AppDbContext db, CampusClock clock, BreakScheduleOptions schedule)
    {
        for (var i = 0; i < schedule.DaysAhead; i++)
        {
            var date = clock.Today.AddDays(i);
            var (from, to) = clock.DayRangeUtc(date);
            if (await db.BreakSlots.AnyAsync(b => b.StartsAt >= from && b.StartsAt < to)) continue;

            foreach (var slot in schedule.Slots)
            {
                var startsAt = clock.ToUtc(date, slot.Start);
                db.BreakSlots.Add(new BreakSlot
                {
                    StartsAt = startsAt,
                    EndsAt = clock.ToUtc(date, slot.End),
                    OrderDeadline = startsAt.AddMinutes(-schedule.OrderDeadlineMinutes),
                });
            }
        }
        await db.SaveChangesAsync();
    }

    /// Staff can't register through the API, so the first accounts come from configuration
    /// ("Seed:Employees"). This is how the SuperAdmin appears. Existing e-mails are left untouched.
    private static async Task EnsureEmployeesAsync(
        AppDbContext db, CampusClock clock, PasswordService passwords, List<SeedEmployee> seed)
    {
        foreach (var item in seed)
        {
            var email = item.Email.Trim().ToLowerInvariant();
            if (await db.Employees.AnyAsync(e => e.Email == email)) continue;

            var employee = new Employee { Email = email, Name = item.Name, Role = item.Role, CreatedAt = clock.UtcNow };
            employee.Credentials = new UserCredentials { PasswordHash = passwords.Hash(employee, item.Password) };
            db.Employees.Add(employee);
        }
        await db.SaveChangesAsync();
    }

    private record SeedEmployee(string Email, string Password, string Name, UserRole Role);

    private static List<Category> DemoMenu() =>
    [
        new()
        {
            Name = "Перші страви", SortOrder = 1, Dishes =
            [
                new() { Name = "Борщ український", Description = "Зі сметаною та пампушкою", Price = 55, WeightG = 300, Kcal = 210, IsPopular = true },
                new() { Name = "Суп курячий з локшиною", Description = "Домашня локшина, зелень", Price = 45, WeightG = 300, Kcal = 160 },
                new() { Name = "Крем-суп грибний", Description = "Печериці, вершки, грінки", Price = 60, WeightG = 250, Kcal = 230 },
            ],
        },
        new()
        {
            Name = "Другі страви", SortOrder = 2, Dishes =
            [
                new() { Name = "Котлета по-київськи", Description = "З картопляним пюре", Price = 95, WeightG = 320, Kcal = 520, IsPopular = true },
                new() { Name = "Вареники з картоплею", Description = "Зі смаженою цибулею та сметаною", Price = 65, WeightG = 280, Kcal = 410, IsPopular = true },
                new() { Name = "Гречка з грибами", Description = "Печериці, цибуля", Price = 55, WeightG = 280, Kcal = 330 },
                new() { Name = "Плов зі свининою", Description = "Рис, морква, спеції", Price = 85, WeightG = 300, Kcal = 480 },
            ],
        },
        new()
        {
            Name = "Салати", SortOrder = 3, Dishes =
            [
                new() { Name = "Олів'є", Description = "Класичний", Price = 45, WeightG = 180, Kcal = 290 },
                new() { Name = "Вінегрет", Description = "Буряк, квасоля, огірок", Price = 35, WeightG = 180, Kcal = 140 },
                new() { Name = "Цезар з куркою", Description = "Романо, пармезан, грінки", Price = 80, WeightG = 220, Kcal = 350, IsPopular = true },
            ],
        },
        new()
        {
            Name = "Випічка", SortOrder = 4, Dishes =
            [
                new() { Name = "Сирник", Description = "Зі сметаною", Price = 30, WeightG = 120, Kcal = 260 },
                new() { Name = "Пиріжок з вишнею", Price = 20, WeightG = 90, Kcal = 230 },
                new() { Name = "Круасан", Description = "Вершкове масло", Price = 35, WeightG = 70, Kcal = 280 },
            ],
        },
        new()
        {
            Name = "Напої", SortOrder = 5, Dishes =
            [
                new() { Name = "Чай чорний", Price = 15, WeightG = 250, Kcal = 5 },
                new() { Name = "Кава американо", Price = 30, WeightG = 200, Kcal = 10, IsPopular = true },
                new() { Name = "Компот", Description = "Сухофрукти", Price = 20, WeightG = 250, Kcal = 90 },
            ],
        },
    ];
}
