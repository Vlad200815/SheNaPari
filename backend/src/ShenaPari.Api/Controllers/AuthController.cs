using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Route("auth")]
[EnableRateLimiting(RateLimits.Auth)]
public class AuthController(AuthService auth) : ControllerBase
{
    [HttpPost("otp/request")]
    public async Task<ActionResult<Result<object?>>> RequestOtp(OtpRequestDto dto) =>
        (await auth.RequestOtpAsync(dto.Phone)).ToActionResult();

    [HttpPost("otp/verify")]
    public async Task<ActionResult<Result<AuthResponseDto>>> VerifyOtp(OtpVerifyDto dto) =>
        (await auth.VerifyOtpAsync(dto.Phone, dto.Code)).ToActionResult();

    // POST /auth/staff/login — canteen staff: e-mail + password
    [HttpPost("staff/login")]
    public async Task<ActionResult<Result<AuthResponseDto>>> StaffLogin(StaffLoginDto dto) =>
        (await auth.StaffLoginAsync(dto.Email, dto.Password)).ToActionResult();

    [HttpPost("refresh")]
    public async Task<ActionResult<Result<AuthResponseDto>>> Refresh(RefreshDto dto) =>
        (await auth.RefreshAsync(dto.RefreshToken)).ToActionResult();

    [Authorize]
    [HttpPost("logout")]
    public async Task<ActionResult<Result<object?>>> Logout(RefreshDto dto)
    {
        await auth.LogoutAsync(User.UserId(), dto.RefreshToken);
        return Result.Ok().ToActionResult();
    }
}
