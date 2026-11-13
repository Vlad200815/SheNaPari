using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("admin/schedules")]
public class AdminSchedulesController(ScheduleService schedules) : ControllerBase
{
    // GET /admin/schedules
    [HttpGet]
    public async Task<ActionResult<Result<List<BellScheduleDto>>>> GetAll() =>
        Result<List<BellScheduleDto>>.Ok(await schedules.GetAllAsync()).ToActionResult();

    // POST /admin/schedules  { name, breaks: [{ start: "09:30", end: "09:40" }, ...] }
    [HttpPost]
    public async Task<ActionResult<Result<BellScheduleDto>>> Create(CreateScheduleDto dto) =>
        (await schedules.CreateAsync(dto)).ToActionResult(successStatus: 201);

    // POST /admin/schedules/{id}/activate — switch the campus to this schedule
    [HttpPost("{id:int}/activate")]
    public async Task<ActionResult<Result<BellScheduleDto>>> Activate(int id) =>
        (await schedules.ActivateAsync(id)).ToActionResult();

    // DELETE /admin/schedules/{id} — only an inactive schedule
    [HttpDelete("{id:int}")]
    public async Task<ActionResult<Result<object?>>> Delete(int id) =>
        (await schedules.DeleteAsync(id)).ToActionResult();
}
