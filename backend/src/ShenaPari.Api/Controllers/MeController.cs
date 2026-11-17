using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Orders;
using ShenaPari.Api.Push;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("me")]
public class MeController(AppDbContext db, PushService push, TimeProvider clock) : ControllerBase
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

    // DELETE /me — the customer deletes their account (required by the app stores).
    // The person is erased: name and phone go, every session and push token is
    // revoked. Orders stay for the canteen's records but no longer point to anyone
    // identifiable. The same phone can sign up again as a new account.
    [HttpDelete]
    public async Task<ActionResult<Result<object?>>> Delete()
    {
        var user = await db.Users.FindAsync(User.UserId());
        if (user is null || !user.IsActive) return Result<object?>.Fail(CommonErrors.Unauthorized).ToActionResult();
        if (user is not Customer customer)
            return Result<object?>.Fail(ProfileErrors.StaffCannotDelete).ToActionResult();

        var activeStatuses = Enum.GetValues<OrderStatus>().Where(OrderStatusRules.IsActive).ToList();
        if (await db.Orders.AnyAsync(o => o.CustomerId == customer.Id && activeStatuses.Contains(o.Status)))
            return Result<object?>.Fail(ProfileErrors.HasActiveOrder).ToActionResult();

        var now = clock.GetUtcNow();
        var oldPhone = customer.Phone;
        customer.Name = null;
        // Phone is required and unique: a placeholder that fits 20 chars frees the real number.
        customer.Phone = $"del-{customer.Id:N}"[..20];
        customer.DeactivatedAt = now;

        await db.RefreshTokens
            .Where(t => t.UserId == customer.Id)
            .ExecuteUpdateAsync(s => s
                .SetProperty(t => t.RevokedAt, t => t.RevokedAt ?? now)
                .SetProperty(t => t.PushToken, (string?)null));
        await db.VerificationCodes.Where(c => c.Phone == oldPhone).ExecuteDeleteAsync();
        await db.SaveChangesAsync();
        return Result.Ok().ToActionResult();
    }

    // PUT /me/push-token  { "token": "<Firebase device token>" } — after login and on token refresh
    [HttpPut("push-token")]
    public async Task<ActionResult<Result<object?>>> SetPushToken(PushTokenDto dto)
    {
        await push.SetDeviceTokenAsync(User.SessionId(), dto.Token);
        return Result.Ok().ToActionResult();
    }

    private static MeDto ToDto(User u) =>
        new(u.Id, u.Role, u.Name, (u as Customer)?.Phone, (u as Employee)?.Email);
}
