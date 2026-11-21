namespace ShenaPari.Api.Entities;

/// The customer's rating of a picked-up order: one per order, changeable
/// for a few days. Tags are codes ("tasty", "cold"): the apps show the text.
public class OrderRating
{
    public Guid OrderId { get; set; }

    /// 1–5.
    public int Stars { get; set; }

    /// Comma-separated codes from RatingTags, in the order they were tapped.
    public string Tags { get; set; } = "";
    public string? Comment { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}
