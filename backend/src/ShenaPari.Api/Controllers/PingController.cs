using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Common;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Route("ping")]
public class PingController : ControllerBase
{
    [HttpGet]
    public ActionResult<Result<string>> Pong() => Result<string>.Ok("pong").ToActionResult();
}
