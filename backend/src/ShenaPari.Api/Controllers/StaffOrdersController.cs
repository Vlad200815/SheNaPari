using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Cook)] // students get 403
[Route("staff/orders")]
public class StaffOrdersController(OrderService orders) : ControllerBase
{
    // GET /staff/orders?breakSlotId=3 — without the parameter: all of today's active orders
    [HttpGet]
    public async Task<ActionResult<Result<List<StaffOrderDto>>>> GetActive(int? breakSlotId) =>
        Result<List<StaffOrderDto>>.Ok(await orders.GetForStaffAsync(breakSlotId)).ToActionResult();

    // PATCH /staff/orders/{id}/status  { "status": "Accepted" }
    [HttpPatch("{id:guid}/status")]
    public async Task<ActionResult<Result<StaffOrderDto>>> ChangeStatus(Guid id, UpdateStatusDto dto) =>
        (await orders.ChangeStatusAsync(id, dto.Status)).ToActionResult();

    // POST /staff/orders/pickup  { "token": "..." } — from the QR scanner
    [HttpPost("pickup")]
    public async Task<ActionResult<Result<StaffOrderDto>>> Pickup(PickupDto dto) =>
        (await orders.PickupAsync(dto.Token)).ToActionResult();
}
