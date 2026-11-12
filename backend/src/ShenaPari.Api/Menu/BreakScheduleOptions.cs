namespace ShenaPari.Api.Menu;

/// Daily break timetable, bound from the "BreakSchedule" section of appsettings.
/// Times are local (Kyiv); the seeder converts them to UTC BreakSlot rows.
public class BreakScheduleOptions
{
    public string TimeZone { get; init; } = "Europe/Kyiv";

    /// Orders for a break close this many minutes before it starts (time to cook).
    public int OrderDeadlineMinutes { get; init; } = 15;

    /// How many days ahead (including today) break slots are created.
    public int DaysAhead { get; init; } = 7;

    public List<BreakTime> Slots { get; init; } = [];
}

/// "11:30" → "11:50"
public record BreakTime(TimeOnly Start, TimeOnly End);
