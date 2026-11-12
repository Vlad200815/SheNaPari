namespace ShenaPari.Api.Entities;

/// A concrete break on a concrete day, generated from the active BellSchedule.
/// A client may pick it as the pickup time until the break starts.
public class BreakSlot
{
    public int Id { get; set; }
    public DateTimeOffset StartsAt { get; set; }
    public DateTimeOffset EndsAt { get; set; }
}
