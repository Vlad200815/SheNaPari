using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("me")]
public class MeController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<MeDto>> Get()
    {
        var u = await db.Users.FindAsync(User.UserId());
        return u is null ? NotFound() : new MeDto(u.Id, u.Phone, u.Name, u.Role.ToString());
    }

    [HttpPatch]
    public async Task<ActionResult<MeDto>> Update(UpdateMeDto dto)
    {
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return Problem("Name must be 2–100 characters", statusCode: 400);

        var u = await db.Users.FindAsync(User.UserId());
        if (u is null) return NotFound();
        u.Name = name;
        await db.SaveChangesAsync();
        return new MeDto(u.Id, u.Phone, u.Name, u.Role.ToString());
    }
}
