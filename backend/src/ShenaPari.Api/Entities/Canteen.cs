namespace ShenaPari.Api.Entities;

/// The canteen itself. One row in the MVP; more rows when other canteens join.
public class Canteen
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public string? NameEn { get; set; }

    /// Kitchen switch: false = "we are overloaded, no new orders for now".
    public bool IsAcceptingOrders { get; set; } = true;

    /// When the kitchen paused (UTC); null while accepting. Pausing again
    /// keeps the first time.
    public DateTimeOffset? PausedAt { get; set; }
}
