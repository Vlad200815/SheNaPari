using Microsoft.Extensions.Options;

namespace ShenaPari.Api.Schedules;

/// Answers "what is today?" in the campus time zone. The server itself may run in UTC,
/// so DateTime.Today would give the wrong day around midnight.
public class CampusClock(TimeProvider clock, IOptions<CampusOptions> options)
{
    private readonly TimeZoneInfo _zone = TimeZoneInfo.FindSystemTimeZoneById(options.Value.TimeZone);

    public DateTimeOffset UtcNow => clock.GetUtcNow();

    public DateOnly Today => DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(UtcNow, _zone).DateTime);

    /// Local campus date + time → UTC instant (handles summer/winter time).
    public DateTimeOffset ToUtc(DateOnly date, TimeOnly time)
    {
        var local = date.ToDateTime(time);
        var offset = _zone.GetUtcOffset(local);
        return new DateTimeOffset(local, offset).ToUniversalTime();
    }

    /// [start, end) of a campus-local day, in UTC.
    public (DateTimeOffset From, DateTimeOffset To) DayRangeUtc(DateOnly date) =>
        (ToUtc(date, TimeOnly.MinValue), ToUtc(date.AddDays(1), TimeOnly.MinValue));
}
