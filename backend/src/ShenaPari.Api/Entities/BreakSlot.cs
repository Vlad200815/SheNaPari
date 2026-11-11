namespace ShenaPari.Api.Entities;

/// A concrete break on a concrete day. Orders are accepted until OrderDeadline.
public class BreakSlot
{
    public int Id { get; set; }
    public DateTimeOffset StartsAt { get; set; }
    public DateTimeOffset EndsAt { get; set; }
    public DateTimeOffset OrderDeadline { get; set; }
}
