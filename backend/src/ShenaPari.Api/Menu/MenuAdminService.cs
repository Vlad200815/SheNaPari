using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Menu;

/// Menu management for admins: categories, dishes, prices and dish photos.
public class MenuAdminService(AppDbContext db, IWebHostEnvironment env)
{
    private const long MaxImageBytes = 5 * 1024 * 1024;
    private const string ImageFolder = "images/dishes";

    private static readonly Dictionary<string, string> ImageTypes = new()
    {
        ["image/jpeg"] = ".jpg",
        ["image/png"] = ".png",
        ["image/webp"] = ".webp",
    };

    // ---------- categories ----------

    public async Task<List<AdminCategoryDto>> GetCategoriesAsync() =>
        await db.Categories
            .OrderBy(c => c.SortOrder)
            .Select(c => new AdminCategoryDto(c.Id, c.Name, c.SortOrder, c.Dishes.Count))
            .ToListAsync();

    public async Task<Result<AdminCategoryDto>> CreateCategoryAsync(SaveCategoryDto dto)
    {
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return MenuErrors.InvalidName;

        var category = new Category { Name = name, SortOrder = dto.SortOrder };
        db.Categories.Add(category);
        await db.SaveChangesAsync();
        return new AdminCategoryDto(category.Id, category.Name, category.SortOrder, 0);
    }

    public async Task<Result<AdminCategoryDto>> UpdateCategoryAsync(int id, SaveCategoryDto dto)
    {
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return MenuErrors.InvalidName;
        var category = await db.Categories.Include(c => c.Dishes).FirstOrDefaultAsync(c => c.Id == id);
        if (category is null) return MenuErrors.CategoryNotFound;

        category.Name = name;
        category.SortOrder = dto.SortOrder;
        await db.SaveChangesAsync();
        return new AdminCategoryDto(category.Id, category.Name, category.SortOrder, category.Dishes.Count);
    }

    public async Task<Result<object?>> DeleteCategoryAsync(int id)
    {
        var category = await db.Categories.FindAsync(id);
        if (category is null) return MenuErrors.CategoryNotFound;
        if (await db.Dishes.AnyAsync(d => d.CategoryId == id)) return MenuErrors.CategoryNotEmpty;

        db.Categories.Remove(category);
        await db.SaveChangesAsync();
        return Result.Ok();
    }

    // ---------- dishes ----------

    public async Task<List<AdminDishDto>> GetDishesAsync()
    {
        var dishes = await db.Dishes.OrderBy(d => d.CategoryId).ThenBy(d => d.Name).ToListAsync();
        return dishes.Select(ToDto).ToList();
    }

    public async Task<Result<AdminDishDto>> CreateDishAsync(SaveDishDto dto)
    {
        if (await ValidateAsync(dto) is { } error) return error;

        var dish = new Dish { Name = dto.Name.Trim() };
        Apply(dish, dto);
        db.Dishes.Add(dish);
        await db.SaveChangesAsync();
        return ToDto(dish);
    }

    /// Changing the price here never touches past orders: they keep their own copy.
    public async Task<Result<AdminDishDto>> UpdateDishAsync(int id, SaveDishDto dto)
    {
        var dish = await db.Dishes.FindAsync(id);
        if (dish is null) return MenuErrors.DishNotFound;
        if (await ValidateAsync(dto) is { } error) return error;

        Apply(dish, dto);
        await db.SaveChangesAsync();
        return ToDto(dish);
    }

    /// A dish that was ever ordered can't be deleted (the history points at it): hide it instead.
    public async Task<Result<object?>> DeleteDishAsync(int id)
    {
        var dish = await db.Dishes.FindAsync(id);
        if (dish is null) return MenuErrors.DishNotFound;
        if (await db.OrderItems.AnyAsync(i => i.DishId == id)) return MenuErrors.DishInUse;

        DeleteImageFile(dish.ImageUrl);
        db.Dishes.Remove(dish);
        await db.SaveChangesAsync();
        return Result.Ok();
    }

    /// Saves the photo under wwwroot/images/dishes and stores its relative URL in the dish.
    public async Task<Result<AdminDishDto>> SetDishImageAsync(int id, IFormFile? file)
    {
        var dish = await db.Dishes.FindAsync(id);
        if (dish is null) return MenuErrors.DishNotFound;
        if (file is null || file.Length == 0 || file.Length > MaxImageBytes
            || !ImageTypes.TryGetValue(file.ContentType, out var extension))
            return MenuErrors.InvalidImage;

        var folder = Path.Combine(env.WebRootPath, ImageFolder);
        Directory.CreateDirectory(folder);
        // A new name per upload, so phones never show a stale cached photo.
        var fileName = $"{id}-{Guid.NewGuid():N}{extension}";
        await using (var stream = File.Create(Path.Combine(folder, fileName)))
            await file.CopyToAsync(stream);

        DeleteImageFile(dish.ImageUrl);
        dish.ImageUrl = $"/{ImageFolder}/{fileName}";
        await db.SaveChangesAsync();
        return ToDto(dish);
    }

    // ---------- helpers ----------

    private async Task<Error?> ValidateAsync(SaveDishDto dto)
    {
        if (dto.Name.Trim().Length is < 2 or > 200) return MenuErrors.InvalidName;
        if (dto.Price is <= 0 or > 100_000) return MenuErrors.InvalidPrice;
        if (dto.WeightG < 0 || dto.Kcal < 0) return MenuErrors.InvalidDish;
        if (dto.Description?.Length > 1000) return MenuErrors.InvalidDish;
        if (!await db.Categories.AnyAsync(c => c.Id == dto.CategoryId)) return MenuErrors.CategoryNotFound;
        return null;
    }

    private static void Apply(Dish dish, SaveDishDto dto)
    {
        dish.CategoryId = dto.CategoryId;
        dish.Name = dto.Name.Trim();
        dish.Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim();
        dish.Price = decimal.Round(dto.Price, 2);
        dish.WeightG = dto.WeightG;
        dish.Kcal = dto.Kcal;
        dish.IsPopular = dto.IsPopular;
        dish.IsAvailable = dto.IsAvailable;
    }

    /// Only files we stored ourselves are removed (never an external URL).
    private void DeleteImageFile(string? imageUrl)
    {
        if (imageUrl is null || !imageUrl.StartsWith($"/{ImageFolder}/")) return;
        var path = Path.Combine(env.WebRootPath, ImageFolder, Path.GetFileName(imageUrl));
        if (File.Exists(path)) File.Delete(path);
    }

    private static AdminDishDto ToDto(Dish d) => new(
        d.Id, d.CategoryId, d.Name, d.Description, d.Price, d.WeightG, d.Kcal, d.ImageUrl, d.IsPopular, d.IsAvailable);
}
