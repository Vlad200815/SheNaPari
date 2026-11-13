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
    // GET /staff/orders — the kitchen's board (orders still in work)
    [HttpGet]
    public async Task<ActionResult<Result<List<StaffOrderDto>>>> GetActive() =>
        Result<List<StaffOrderDto>>.Ok(await orders.GetActiveAsync()).ToActionResult();

    // POST /staff/orders/{id}/accept  { "minutes": 15 } — 5, 10, 15 or 20
    [HttpPost("{id:guid}/accept")]
    public async Task<ActionResult<Result<StaffOrderDto>>> Accept(Guid id, AcceptOrderDto dto) =>
        (await orders.AcceptAsync(User.UserId(), id, dto.Minutes)).ToActionResult();

    // PATCH /staff/orders/{id}/status  { "status": "Cooking" | "Ready" | "Cancelled" | "NotPickedUp" | "PickedUp", "reason": "..." }
    [HttpPatch("{id:guid}/status")]
    public async Task<ActionResult<Result<StaffOrderDto>>> ChangeStatus(Guid id, UpdateStatusDto dto) =>
        (await orders.ChangeStatusAsync(User.UserId(), id, dto.Status, dto.Reason)).ToActionResult();

    // POST /staff/orders/pickup  { "token": "..." } — from the QR scanner
    [HttpPost("pickup")]
    public async Task<ActionResult<Result<StaffOrderDto>>> Pickup(PickupDto dto) =>
        (await orders.PickupAsync(User.UserId(), dto.Token)).ToActionResult();
}
