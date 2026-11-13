namespace ShenaPari.Api.Schedules;

/// Bound from the "Campus" section of appsettings.
public class CampusOptions
{
    /// Bell times are stored as local campus time and converted to UTC with this zone.
    public string TimeZone { get; init; } = "Europe/Kyiv";

    /// How many days ahead (including today) break slots are created.
    public int DaysAhead { get; init; } = 7;
}
