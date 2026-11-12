using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("breaks")]
public class BreaksController(AppDbContext db, CampusClock clock) : ControllerBase
{
    // GET /breaks — today's breaks that haven't started yet
    [HttpGet]
    public async Task<ActionResult<Result<List<BreakSlotDto>>>> GetToday()
    {
        var (_, endOfToday) = clock.DayRangeUtc(clock.Today);
        var now = clock.UtcNow;
        var breaks = await db.BreakSlots
            .Where(b => b.StartsAt > now && b.StartsAt < endOfToday)
            .OrderBy(b => b.StartsAt)
            .Select(b => new BreakSlotDto(b.Id, b.StartsAt, b.EndsAt))
            .ToListAsync();
        return Result<List<BreakSlotDto>>.Ok(breaks).ToActionResult();
    }

    // GET /breaks/next — nearest upcoming break (may be tomorrow); data = null if none
    [HttpGet("next")]
    public async Task<ActionResult<Result<BreakSlotDto>>> GetNext()
    {
        var now = clock.UtcNow;
        var next = await db.BreakSlots
            .Where(b => b.StartsAt > now)
            .OrderBy(b => b.StartsAt)
            .Select(b => new BreakSlotDto(b.Id, b.StartsAt, b.EndsAt))
            .FirstOrDefaultAsync();
        return Result<BreakSlotDto>.Ok(next).ToActionResult();
    }
}
