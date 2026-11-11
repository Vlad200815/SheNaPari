namespace ShenaPari.Api.Entities;

public class OrderItem
{
    public int Id { get; set; }
    public Guid OrderId { get; set; }
    public Order Order { get; set; } = null!;
    public int DishId { get; set; }
    public Dish Dish { get; set; } = null!;
    public int Quantity { get; set; }

    /// Price copied at order time so later menu changes don't rewrite history.
    public decimal UnitPrice { get; set; }
}
