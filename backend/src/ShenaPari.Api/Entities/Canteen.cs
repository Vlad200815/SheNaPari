namespace ShenaPari.Api.Entities;

/// The canteen itself. One row in the MVP; more rows when other canteens join.
public class Canteen
{
    public int Id { get; set; }
    public required string Name { get; set; }

    /// Kitchen switch: false = "we are overloaded, no new orders for now".
    public bool IsAcceptingOrders { get; set; } = true;
}
