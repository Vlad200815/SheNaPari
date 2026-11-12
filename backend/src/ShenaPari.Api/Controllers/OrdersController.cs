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
    // POST /orders
    [HttpPost]
    public async Task<ActionResult<Result<OrderDto>>> Create(CreateOrderDto dto) =>
        (await orders.CreateAsync(User.UserId(), dto)).ToActionResult(successStatus: 201);

    // GET /orders/my
    [HttpGet("my")]
    public async Task<ActionResult<Result<List<OrderDto>>>> GetMy() =>
        Result<List<OrderDto>>.Ok(await orders.GetMyAsync(User.UserId())).ToActionResult();

    // GET /orders/{id}
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<Result<OrderDto>>> GetById(Guid id)
    {
        var order = await orders.GetMineByIdAsync(User.UserId(), id);
        Result<OrderDto> result = order is null ? OrderErrors.NotFound : order;
        return result.ToActionResult();
    }
}
