using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Canteens;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
public class CanteenController(CanteenService canteen) : ControllerBase
{
    // GET /canteen — is the kitchen taking orders right now?
    [HttpGet("canteen")]
    public async Task<ActionResult<Result<CanteenDto>>> Get() =>
        Result<CanteenDto>.Ok(await canteen.GetAsync()).ToActionResult();

    // PUT /staff/canteen/accepting  { "isAcceptingOrders": false } — pause / resume
    [Authorize(Policy = Policies.Cook)]
    [HttpPut("staff/canteen/accepting")]
    public async Task<ActionResult<Result<CanteenDto>>> SetAccepting(SetAcceptingDto dto) =>
        Result<CanteenDto>.Ok(await canteen.SetAcceptingAsync(dto.IsAcceptingOrders)).ToActionResult();
}
