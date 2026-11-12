using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("me")]
public class MeController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<Result<MeDto>>> Get()
    {
        var user = await db.Users.FindAsync(User.UserId());
        Result<MeDto> result = user is null ? CommonErrors.Unauthorized : ToDto(user);
        return result.ToActionResult();
    }

    [HttpPatch]
    public async Task<ActionResult<Result<MeDto>>> Update(UpdateMeDto dto)
    {
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return Result<MeDto>.Fail(ProfileErrors.InvalidName).ToActionResult();

        var user = await db.Users.FindAsync(User.UserId());
        if (user is null) return Result<MeDto>.Fail(CommonErrors.Unauthorized).ToActionResult();

        user.Name = name;
        await db.SaveChangesAsync();
        return Result<MeDto>.Ok(ToDto(user)).ToActionResult();
    }

    private static MeDto ToDto(User u) =>
        new(u.Id, u.Role, u.Name, (u as Customer)?.Phone, (u as Employee)?.Email);
}
