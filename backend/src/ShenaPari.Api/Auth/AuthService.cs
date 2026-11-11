using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Auth;

/// Result of an auth operation: either a value or an error the controller maps to HTTP.
public record AuthResult<T>(T? Value, AuthError? Error)
{
    public static AuthResult<T> Ok(T value) => new(value, null);
    public static AuthResult<T> Fail(AuthError error) => new(default, error);
}

public enum AuthError
{
    InvalidPhone,
    TooManyRequests, // asked for a new code within 60 s
    InvalidCode,     // wrong, expired or no code
    TooManyAttempts, // 5 wrong attempts on one code
    InvalidToken,    // refresh token unknown, expired or revoked
}

public partial class AuthService(
    AppDbContext db,
    ISmsSender sms,
    TokenService tokens,
    TimeProvider clock)
{
    private static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(5);
    private static readonly TimeSpan ResendCooldown = TimeSpan.FromSeconds(60);
    private const int MaxAttempts = 5;

    [System.Text.RegularExpressions.GeneratedRegex(@"^\+380\d{9}$")]
    private static partial System.Text.RegularExpressions.Regex UaPhone();

    public async Task<AuthResult<bool>> RequestOtpAsync(string phone)
    {
        if (!UaPhone().IsMatch(phone)) return AuthResult<bool>.Fail(AuthError.InvalidPhone);

        var now = clock.GetUtcNow();
        var last = await db.OtpCodes
            .Where(o => o.Phone == phone)
            .OrderByDescending(o => o.CreatedAt)
            .FirstOrDefaultAsync();
        if (last is not null && now - last.CreatedAt < ResendCooldown)
            return AuthResult<bool>.Fail(AuthError.TooManyRequests);

        // Only one live code per phone: old ones are deleted.
        await db.OtpCodes.Where(o => o.Phone == phone).ExecuteDeleteAsync();

        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        db.OtpCodes.Add(new OtpCode
        {
            Phone = phone,
            CodeHash = HashCode(phone, code),
            ExpiresAt = now + CodeLifetime,
            CreatedAt = now,
        });
        await db.SaveChangesAsync();

        await sms.SendAsync(phone, $"ShenaPari code: {code}");
        return AuthResult<bool>.Ok(true);
    }

    public async Task<AuthResult<AuthResponseDto>> VerifyOtpAsync(string phone, string code)
    {
        var now = clock.GetUtcNow();
        var otp = await db.OtpCodes.FirstOrDefaultAsync(o => o.Phone == phone);
        if (otp is null || otp.ExpiresAt < now)
            return AuthResult<AuthResponseDto>.Fail(AuthError.InvalidCode);
        if (otp.Attempts >= MaxAttempts)
            return AuthResult<AuthResponseDto>.Fail(AuthError.TooManyAttempts);

        var ok = CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(otp.CodeHash),
            Encoding.UTF8.GetBytes(HashCode(phone, code)));
        if (!ok)
        {
            otp.Attempts++;
            await db.SaveChangesAsync();
            return AuthResult<AuthResponseDto>.Fail(AuthError.InvalidCode);
        }

        db.OtpCodes.Remove(otp);

        var user = await db.Users.FirstOrDefaultAsync(u => u.Phone == phone);
        if (user is null)
        {
            user = new User { Phone = phone, CreatedAt = now };
            db.Users.Add(user);
        }

        var response = IssueTokens(user);
        await db.SaveChangesAsync();
        return AuthResult<AuthResponseDto>.Ok(response);
    }

    /// Rotation: the old refresh token is revoked and a new pair is issued.
    public async Task<AuthResult<AuthResponseDto>> RefreshAsync(string refreshToken)
    {
        var hash = TokenService.Hash(refreshToken);
        var stored = await db.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == hash);
        if (stored is null || stored.RevokedAt is not null || stored.ExpiresAt < clock.GetUtcNow())
            return AuthResult<AuthResponseDto>.Fail(AuthError.InvalidToken);

        stored.RevokedAt = clock.GetUtcNow();
        var response = IssueTokens(stored.User);
        await db.SaveChangesAsync();
        return AuthResult<AuthResponseDto>.Ok(response);
    }

    public async Task LogoutAsync(Guid userId, string refreshToken)
    {
        var hash = TokenService.Hash(refreshToken);
        await db.RefreshTokens
            .Where(t => t.UserId == userId && t.TokenHash == hash && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedAt, clock.GetUtcNow()));
    }

    private AuthResponseDto IssueTokens(User user)
    {
        var (raw, entity) = tokens.CreateRefreshToken(user.Id);
        entity.User = user;
        db.RefreshTokens.Add(entity);
        return new AuthResponseDto(
            tokens.CreateAccessToken(user),
            raw,
            IsNew: string.IsNullOrWhiteSpace(user.Name));
    }

    // Phone is mixed in so equal codes for different phones have different hashes.
    private static string HashCode(string phone, string code) => TokenService.Hash($"{phone}:{code}");
}
