using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Data;

/// Fills an empty database with a demo menu, seeds the bell schedules, creates break slots for the coming days
/// and creates the staff accounts listed in configuration. Safe to run on every startup.
public static class DbSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var clock = scope.ServiceProvider.GetRequiredService<CampusClock>();
        var schedules = scope.ServiceProvider.GetRequiredService<ScheduleService>();
        var env = scope.ServiceProvider.GetRequiredService<IHostEnvironment>();
        var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();
        var passwords = scope.ServiceProvider.GetRequiredService<PasswordService>();

        await db.Database.MigrateAsync(); // creates/updates the SQLite file automatically

        if (!await db.Categories.AnyAsync())
        {
            db.Categories.AddRange(DemoMenu());
            await db.SaveChangesAsync();
        }

        if (!await db.Canteens.AnyAsync())
        {
            db.Canteens.Add(new Canteen { Name = "Їдальня, корпус 1" });
            await db.SaveChangesAsync();
        }

        if (!await db.BellSchedules.AnyAsync())
        {
            await SeedSchedulesAsync(db, withTestSchedule: env.IsDevelopment());
            await schedules.RebuildSlotsAsync(); // drop slots made by older versions of the app
        }
        await schedules.EnsureSlotsAsync();
        await EnsureEmployeesAsync(db, clock, passwords,
            config.GetSection("Seed:Employees").Get<List<SeedEmployee>>() ?? []);
    }

    /// First run: the two real bell schedules of the university. The shortened one is active
    /// this semester; an admin can switch at any time (POST /admin/schedules/{id}/activate).
    private static async Task SeedSchedulesAsync(AppDbContext db, bool withTestSchedule)
    {
        db.BellSchedules.Add(Schedule("Основний", isActive: false,
            // 80-minute classes from 8:30, 10-minute breaks, long break after the 3rd class
            ("09:50", "10:00"), ("11:20", "11:30"), ("12:50", "13:20"), ("14:40", "14:50"),
            ("16:10", "16:20"), ("17:40", "17:50"), ("19:10", "19:20")));
        db.BellSchedules.Add(Schedule("Скорочений", isActive: true,
            // 60-minute classes from 8:30, long break after the 4th class
            ("09:30", "09:40"), ("10:40", "10:50"), ("11:50", "12:00"), ("13:00", "13:30"),
            ("14:30", "14:40"), ("15:40", "15:50"), ("16:50", "17:00")));
        if (withTestSchedule)
        {
            // Development only: a break every hour, to try ordering at any time of day.
            db.BellSchedules.Add(Schedule("Тестовий (щогодини)", isActive: false,
                Enumerable.Range(0, 24).Select(h => ($"{h:00}:00", $"{h:00}:20")).ToArray()));
        }
        await db.SaveChangesAsync();
    }

    private static BellSchedule Schedule(string name, bool isActive, params (string Start, string End)[] breaks) => new()
    {
        Name = name,
        IsActive = isActive,
        Breaks = breaks
            .Select(b => new BellScheduleBreak { Start = TimeOnly.Parse(b.Start), End = TimeOnly.Parse(b.End) })
            .ToList(),
    };

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
