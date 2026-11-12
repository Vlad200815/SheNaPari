namespace ShenaPari.Api.Entities;

public class OrderItem
{
    public int Id { get; set; }
    public Guid OrderId { get; set; }
    public Order Order { get; set; } = null!;
    public int DishId { get; set; }
    public Dish Dish { get; set; } = null!;
    public int Quantity { get; set; }

    /// Name and price copied at order time, so later menu edits don't rewrite history.
    public required string NameSnapshot { get; set; }
    public decimal UnitPrice { get; set; }
}
