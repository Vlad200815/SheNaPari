using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Customer)] // staff accounts don't place orders
[Route("orders")]
public class OrdersController(OrderService orders) : ControllerBase
{
    // POST /orders  { breakSlotId: 12 | null, paymentProvider: "GooglePay", items: [...] }
    [HttpPost]
    public async Task<ActionResult<Result<OrderDto>>> Create(CreateOrderDto dto) =>
        (await orders.CreateAsync(User.UserId(), dto)).ToActionResult(successStatus: 201);

    // GET /orders/my?active=true — only the orders still in work; without it, every order
    [HttpGet("my")]
    public async Task<ActionResult<Result<List<OrderDto>>>> GetMy(bool active = false) =>
        Result<List<OrderDto>>.Ok(await orders.GetMyAsync(User.UserId(), active)).ToActionResult();

    // GET /orders/my/history?status=Cancelled&before=2026-11-18T10:12:00Z&limit=20
    // Finished orders, newest first; the next page is `before` = createdAt of the last one.
    [HttpGet("my/history")]
    public async Task<ActionResult<Result<OrderHistoryDto>>> GetHistory(
        OrderStatus? status, DateTimeOffset? before, int limit = OrderService.HistoryPageSize) =>
        (await orders.GetHistoryAsync(User.UserId(), status, before, limit)).ToActionResult();

    // GET /orders/{id}
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<Result<OrderDto>>> GetById(Guid id) =>
        (await orders.GetMineByIdAsync(User.UserId(), id)).ToActionResult();

    // POST /orders/{id}/cancel — until the kitchen starts cooking
    [HttpPost("{id:guid}/cancel")]
    public async Task<ActionResult<Result<OrderDto>>> Cancel(Guid id) =>
        (await orders.CancelByCustomerAsync(User.UserId(), id)).ToActionResult();
}
