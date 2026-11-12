using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Schedules;

public class ScheduleService(AppDbContext db, CampusClock clock, IOptions<CampusOptions> options)
{
    public async Task<List<BellScheduleDto>> GetAllAsync()
    {
        var list = await db.BellSchedules.Include(s => s.Breaks).OrderBy(s => s.Id).ToListAsync();
        return list.Select(ToDto).ToList();
    }

    public async Task<Result<BellScheduleDto>> CreateAsync(CreateScheduleDto dto)
    {
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return ScheduleErrors.InvalidName;
        if (await db.BellSchedules.AnyAsync(s => s.Name == name)) return ScheduleErrors.NameTaken;
        if (!AreValid(dto.Breaks)) return ScheduleErrors.InvalidBreaks;

        var schedule = new BellSchedule
        {
            Name = name,
            Breaks = dto.Breaks.Select(b => new BellScheduleBreak { Start = b.Start, End = b.End }).ToList(),
        };
        db.BellSchedules.Add(schedule);
        await db.SaveChangesAsync();
        return ToDto(schedule);
    }

    /// Makes this schedule the only active one and rebuilds the upcoming break slots from it.
    public async Task<Result<BellScheduleDto>> ActivateAsync(int id)
    {
        var all = await db.BellSchedules.Include(s => s.Breaks).ToListAsync();
        var target = all.FirstOrDefault(s => s.Id == id);
        if (target is null) return ScheduleErrors.NotFound;

        foreach (var s in all) s.IsActive = s.Id == id;
        await db.SaveChangesAsync();

        await RebuildSlotsAsync();
        return ToDto(target);
    }

    public async Task<Result<object?>> DeleteAsync(int id)
    {
        var schedule = await db.BellSchedules.FindAsync(id);
        if (schedule is null) return ScheduleErrors.NotFound;
        if (schedule.IsActive) return ScheduleErrors.ActiveCannotBeDeleted;

        db.BellSchedules.Remove(schedule); // its breaks go with it (cascade)
        await db.SaveChangesAsync();
        return Result.Ok();
    }

    /// After a schedule switch: upcoming slots nobody ordered for are dropped and regenerated.
    /// Slots that already have orders stay, so those clients keep their pickup time.
    public async Task RebuildSlotsAsync()
    {
        var now = clock.UtcNow;
        await db.BreakSlots
            .Where(b => b.StartsAt > now && !db.Orders.Any(o => o.BreakSlotId == b.Id))
            .ExecuteDeleteAsync();
        await EnsureSlotsAsync();
    }

    /// Creates the missing break slots for today and the next days from the active schedule.
    /// Safe to call any number of times (startup, hourly timer, after a switch).
    public async Task EnsureSlotsAsync()
    {
        var active = await db.BellSchedules.Include(s => s.Breaks).FirstOrDefaultAsync(s => s.IsActive);
        if (active is null) return;

        var now = clock.UtcNow;
        var (from, _) = clock.DayRangeUtc(clock.Today);
        var existing = (await db.BreakSlots.Where(b => b.StartsAt >= from).Select(b => b.StartsAt).ToListAsync())
            .ToHashSet();

        for (var day = 0; day < options.Value.DaysAhead; day++)
        {
            var date = clock.Today.AddDays(day);
            foreach (var b in active.Breaks)
            {
                var startsAt = clock.ToUtc(date, b.Start);
                var endsAt = clock.ToUtc(date, b.End);
                if (endsAt <= now || existing.Contains(startsAt)) continue;
                db.BreakSlots.Add(new BreakSlot { StartsAt = startsAt, EndsAt = endsAt });
            }
        }
        await db.SaveChangesAsync();
    }

    /// Each break must end after it starts, and breaks must not overlap.
    private static bool AreValid(List<BellBreakDto> breaks)
    {
        if (breaks.Count is 0 or > 20) return false;
        var sorted = breaks.OrderBy(b => b.Start).ToList();
        for (var i = 0; i < sorted.Count; i++)
        {
            if (sorted[i].End <= sorted[i].Start) return false;
            if (i > 0 && sorted[i].Start < sorted[i - 1].End) return false;
        }
        return true;
    }

    private static BellScheduleDto ToDto(BellSchedule s) => new(
        s.Id, s.Name, s.IsActive,
        s.Breaks.OrderBy(b => b.Start).Select(b => new BellBreakDto(b.Start, b.End)).ToList());
}
