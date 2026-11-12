namespace ShenaPari.Api.Dtos;

// DTO = what the API returns. We never return Entities directly:
// they have navigation properties (Category.Dishes → Dish.Category → ...)
// that create JSON cycles and leak DB details to the client.
public record CategoryDto(int Id, string Name);

public record DishDto(
    int Id,
    int CategoryId,
    string Name,
    string? Description,
    decimal Price,
    int WeightG,
    int Kcal,
    string? ImageUrl,
    bool IsPopular);

public record BreakSlotDto(int Id, DateTimeOffset StartsAt, DateTimeOffset EndsAt);
