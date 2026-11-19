namespace ShenaPari.Api.Dtos;

/// NameEn: shown to clients that ask for English; empty → the Ukrainian name.
public record SaveCategoryDto(string Name, int SortOrder, string? NameEn = null);

public record AdminCategoryDto(int Id, string Name, string? NameEn, int SortOrder, int DishCount);

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
