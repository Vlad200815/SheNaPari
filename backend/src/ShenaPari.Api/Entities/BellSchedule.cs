namespace ShenaPari.Api.Entities;

/// A named timetable of breaks ("Основний", "Скорочений"). Exactly one is active;
/// break slots for the coming days are generated from it.
public class BellSchedule
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public bool IsActive { get; set; }

    public List<BellScheduleBreak> Breaks { get; set; } = [];
}

/// One break of a schedule, in local campus time (no date): 13:00–13:30.
public class BellScheduleBreak
{
    public int Id { get; set; }
    public int BellScheduleId { get; set; }
    public TimeOnly Start { get; set; }
    public TimeOnly End { get; set; }
}
