namespace ShenaPari.Api.Entities;

public class Dish
{
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;
    public required string Name { get; set; }
    public string? Description { get; set; }

    /// English texts for clients that ask for English; null → the Ukrainian ones.
    public string? NameEn { get; set; }
    public string? DescriptionEn { get; set; }
    public decimal Price { get; set; }
    public int WeightG { get; set; }
    public int Kcal { get; set; }

    /// Grams per portion; null while the kitchen hasn't filled them in.
    public int? ProteinG { get; set; }
    public int? FatG { get; set; }
    public int? CarbsG { get; set; }

    /// 0 not spicy, 1 a little, 2 spicy, 3 very spicy.
    public int SpicyLevel { get; set; }

    /// No animal products at all (no meat, fish, milk, eggs, honey).
    public bool IsVegan { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsAvailable { get; set; } = true;
    public bool IsPopular { get; set; }
}
