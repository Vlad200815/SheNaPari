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
            db.Canteens.Add(new Canteen { Name = "Їдальня, корпус 1", NameEn = "Canteen, building 1" });
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

    /// What a canteen near the university actually sells: fast food first, then hot dishes.
    private static List<Category> DemoMenu() =>
    [
        new()
        {
            Name = "Бургери", NameEn = "Burgers", SortOrder = 1, Dishes =
            [
                new() { Name = "Чизбургер", Description = "Яловича котлета, сир чедер, солоний огірок, соус", NameEn = "Cheeseburger", DescriptionEn = "Beef patty, cheddar, pickles, sauce", Price = 95, WeightG = 220, Kcal = 480, IsPopular = true, ProteinG = 26, FatG = 24, CarbsG = 40 },
                new() { Name = "Бургер з куркою", Description = "Куряче філе в паніруванні, салат, томат, соус", NameEn = "Chicken burger", DescriptionEn = "Breaded chicken fillet, lettuce, tomato, sauce", Price = 105, WeightG = 240, Kcal = 510, ProteinG = 32, FatG = 21, CarbsG = 48 },
                new() { Name = "Подвійний бургер", Description = "Дві яловичі котлети, подвійний сир, бекон", NameEn = "Double burger", DescriptionEn = "Two beef patties, double cheese, bacon", Price = 135, WeightG = 320, Kcal = 760, ProteinG = 44, FatG = 44, CarbsG = 46 },
            ],
        },
        new()
        {
            Name = "Хот-доги", NameEn = "Hot dogs", SortOrder = 2, Dishes =
            [
                new() { Name = "Хот-дог класичний", Description = "Сосиска, кетчуп, гірчиця, маринована цибуля", NameEn = "Classic hot dog", DescriptionEn = "Sausage, ketchup, mustard, pickled onion", Price = 55, WeightG = 180, Kcal = 390, IsPopular = true, ProteinG = 13, FatG = 22, CarbsG = 35, SpicyLevel = 1 },
                new() { Name = "Хот-дог із сиром", Description = "Сосиска, сирний соус, хрустка цибуля", NameEn = "Cheese hot dog", DescriptionEn = "Sausage, cheese sauce, crispy onion", Price = 65, WeightG = 200, Kcal = 450, ProteinG = 16, FatG = 26, CarbsG = 38 },
                new() { Name = "Французький хот-дог", Description = "Сосиска в багеті, часниковий соус", NameEn = "French hot dog", DescriptionEn = "Sausage in a baguette, garlic sauce", Price = 60, WeightG = 190, Kcal = 420, ProteinG = 14, FatG = 23, CarbsG = 39 },
            ],
        },
        new()
        {
            Name = "Багети", NameEn = "Baguettes", SortOrder = 3, Dishes =
            [
                new() { Name = "Багет із шинкою і сиром", Description = "Шинка, сир, салат, томат", NameEn = "Ham and cheese baguette", DescriptionEn = "Ham, cheese, lettuce, tomato", Price = 75, WeightG = 230, Kcal = 430, ProteinG = 22, FatG = 16, CarbsG = 50 },
                new() { Name = "Багет із куркою", Description = "Куряче філе, овочі, соус цезар", NameEn = "Chicken baguette", DescriptionEn = "Chicken fillet, vegetables, Caesar dressing", Price = 85, WeightG = 250, Kcal = 460, IsPopular = true, ProteinG = 28, FatG = 16, CarbsG = 51 },
                new() { Name = "Багет із тунцем", Description = "Тунець, яйце, огірок, майонез", NameEn = "Tuna baguette", DescriptionEn = "Tuna, egg, cucumber, mayonnaise", Price = 90, WeightG = 240, Kcal = 440, ProteinG = 24, FatG = 18, CarbsG = 45 },
                new() { Name = "Фалафель у піті", Description = "Фалафель, хумус, овочі, гострий соус", NameEn = "Falafel pita", DescriptionEn = "Falafel, hummus, vegetables, hot sauce", Price = 95, WeightG = 260, Kcal = 480, ProteinG = 16, FatG = 20, CarbsG = 58, SpicyLevel = 2, IsVegan = true },
            ],
        },
        new()
        {
            Name = "Гарячі страви", NameEn = "Hot meals", SortOrder = 4, Dishes =
            [
                new() { Name = "Борщ український", Description = "Зі сметаною та пампушкою", NameEn = "Ukrainian borscht", DescriptionEn = "With sour cream and a garlic bun", Price = 55, WeightG = 300, Kcal = 210, IsPopular = true, ProteinG = 7, FatG = 9, CarbsG = 25 },
                new() { Name = "Суп курячий з локшиною", Description = "Домашня локшина, зелень", NameEn = "Chicken noodle soup", DescriptionEn = "Homemade noodles, herbs", Price = 45, WeightG = 300, Kcal = 160, ProteinG = 11, FatG = 5, CarbsG = 18 },
                new() { Name = "Вареники з картоплею", Description = "Зі смаженою цибулею та сметаною", NameEn = "Potato varenyky", DescriptionEn = "With fried onion and sour cream", Price = 65, WeightG = 280, Kcal = 410, ProteinG = 10, FatG = 14, CarbsG = 61 },
                new() { Name = "Котлета по-київськи", Description = "З картопляним пюре", NameEn = "Chicken Kyiv", DescriptionEn = "With mashed potatoes", Price = 95, WeightG = 320, Kcal = 520, ProteinG = 26, FatG = 30, CarbsG = 36 },
            ],
        },
        new()
        {
            Name = "Випічка", NameEn = "Pastries", SortOrder = 5, Dishes =
            [
                new() { Name = "Сирник", Description = "Зі сметаною", NameEn = "Syrnyk", DescriptionEn = "With sour cream", Price = 30, WeightG = 120, Kcal = 260, ProteinG = 15, FatG = 11, CarbsG = 25 },
                new() { Name = "Пиріжок з вишнею", NameEn = "Cherry pie", Price = 20, WeightG = 90, Kcal = 230, ProteinG = 4, FatG = 8, CarbsG = 36 },
                new() { Name = "Круасан", Description = "Вершкове масло", NameEn = "Croissant", DescriptionEn = "Butter", Price = 35, WeightG = 70, Kcal = 280, ProteinG = 5, FatG = 16, CarbsG = 29 },
            ],
        },
        new()
        {
            Name = "Напої", NameEn = "Drinks", SortOrder = 6, Dishes =
            [
                new() { Name = "Чай чорний", NameEn = "Black tea", Price = 15, WeightG = 250, Kcal = 5, ProteinG = 0, FatG = 0, CarbsG = 1, IsVegan = true },
                new() { Name = "Кава американо", NameEn = "Americano", Price = 30, WeightG = 200, Kcal = 10, IsPopular = true, ProteinG = 0, FatG = 0, CarbsG = 2, IsVegan = true },
                new() { Name = "Компот", Description = "Сухофрукти", NameEn = "Kompot", DescriptionEn = "Dried fruit", Price = 20, WeightG = 250, Kcal = 90, ProteinG = 0, FatG = 0, CarbsG = 22, IsVegan = true },
            ],
        },
    ];
}
