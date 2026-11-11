namespace ShenaPari.Api.Entities;

public class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public int SortOrder { get; set; }

    public List<Dish> Dishes { get; set; } = [];
}
