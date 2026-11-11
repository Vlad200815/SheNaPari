using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Route("auth")]
public class AuthController(AuthService auth) : ControllerBase
{
    [HttpPost("otp/request")]
    public async Task<IActionResult> RequestOtp(OtpRequestDto dto)
    {
        var result = await auth.RequestOtpAsync(dto.Phone);
        return result.Error is { } e ? ToProblem(e) : NoContent();
    }

    [HttpPost("otp/verify")]
    public async Task<ActionResult<AuthResponseDto>> VerifyOtp(OtpVerifyDto dto)
    {
        var result = await auth.VerifyOtpAsync(dto.Phone, dto.Code);
        return result.Error is { } e ? ToProblem(e) : result.Value!;
    }

    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponseDto>> Refresh(RefreshDto dto)
    {
        var result = await auth.RefreshAsync(dto.RefreshToken);
        return result.Error is { } e ? ToProblem(e) : result.Value!;
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(RefreshDto dto)
    {
        await auth.LogoutAsync(User.UserId(), dto.RefreshToken);
        return NoContent();
    }

    private ObjectResult ToProblem(AuthError error) => error switch
    {
        AuthError.InvalidPhone => Problem("Phone must look like +380XXXXXXXXX", statusCode: 400),
        AuthError.TooManyRequests => Problem("Wait 60 seconds before requesting a new code", statusCode: 429),
        AuthError.InvalidCode => Problem("Invalid or expired code", statusCode: 400),
        AuthError.TooManyAttempts => Problem("Too many attempts, request a new code", statusCode: 429),
        AuthError.InvalidToken => Problem("Invalid refresh token", statusCode: 401),
        _ => Problem(statusCode: 500),
    };
}
