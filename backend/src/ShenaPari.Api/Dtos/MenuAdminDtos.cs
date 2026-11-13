namespace ShenaPari.Api.Dtos;

public record SaveCategoryDto(string Name, int SortOrder);

public record AdminCategoryDto(int Id, string Name, int SortOrder, int DishCount);

public record SaveDishDto(
    int CategoryId,
    string Name,
    string? Description,
    decimal Price,
    int WeightG,
    int Kcal,
    bool IsPopular = false,
    bool IsAvailable = true);

/// Admin view of a dish: everything, including whether clients can see it.
public record AdminDishDto(
    int Id,
    int CategoryId,
    string Name,
    string? Description,
    decimal Price,
    int WeightG,
    int Kcal,
    string? ImageUrl,
    bool IsPopular,
    bool IsAvailable);
