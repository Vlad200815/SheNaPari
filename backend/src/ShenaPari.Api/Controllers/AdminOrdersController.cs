using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Orders;
using ShenaPari.Api.Schedules;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("admin/orders")]
public class AdminOrdersController(OrderService orders, CampusClock clock) : ControllerBase
{
    // GET /admin/orders?date=2026-11-12 — all orders of a day with their history (default: today)
    [HttpGet]
    public async Task<ActionResult<Result<List<StaffOrderDto>>>> GetByDay(DateOnly? date) =>
        Result<List<StaffOrderDto>>.Ok(await orders.GetByDayAsync(date ?? clock.Today)).ToActionResult();
}
