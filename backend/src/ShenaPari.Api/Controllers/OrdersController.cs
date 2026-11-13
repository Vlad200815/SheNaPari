using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
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

    // GET /orders/my
    [HttpGet("my")]
    public async Task<ActionResult<Result<List<OrderDto>>>> GetMy() =>
        Result<List<OrderDto>>.Ok(await orders.GetMyAsync(User.UserId())).ToActionResult();

    // GET /orders/{id}
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<Result<OrderDto>>> GetById(Guid id) =>
        (await orders.GetMineByIdAsync(User.UserId(), id)).ToActionResult();

    // POST /orders/{id}/cancel — until the kitchen starts cooking
    [HttpPost("{id:guid}/cancel")]
    public async Task<ActionResult<Result<OrderDto>>> Cancel(Guid id) =>
        (await orders.CancelByCustomerAsync(User.UserId(), id)).ToActionResult();
}
