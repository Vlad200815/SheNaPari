using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Auth;

public partial class AuthService(
    AppDbContext db,
    ISmsSender sms,
    TokenService tokens,
    PasswordService passwords,
    TimeProvider clock)
{
    private static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(5);
    private static readonly TimeSpan ResendCooldown = TimeSpan.FromSeconds(60);
    private const int MaxAttempts = 5;

    [System.Text.RegularExpressions.GeneratedRegex(@"^\+380\d{9}$")]
    private static partial System.Text.RegularExpressions.Regex UaPhone();

    public async Task<Result<object?>> RequestOtpAsync(string phone)
    {
        if (!UaPhone().IsMatch(phone)) return AuthErrors.InvalidPhone;

        var now = clock.GetUtcNow();
        var last = await db.VerificationCodes
            .Where(o => o.Phone == phone)
            .OrderByDescending(o => o.CreatedAt)
            .FirstOrDefaultAsync();
        if (last is not null && now - last.CreatedAt < ResendCooldown)
            return AuthErrors.TooManyRequests;

        // Only one live code per phone: old ones are deleted.
        await db.VerificationCodes.Where(o => o.Phone == phone).ExecuteDeleteAsync();

        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        db.VerificationCodes.Add(new VerificationCode
        {
            Phone = phone,
            CodeHash = HashCode(phone, code),
            ExpiresAt = now + CodeLifetime,
            CreatedAt = now,
        });
        await db.SaveChangesAsync();

        await sms.SendAsync(phone, $"ShenaPari code: {code}");
        return Result.Ok();
    }

    public async Task<Result<AuthResponseDto>> VerifyOtpAsync(string phone, string code)
    {
        var now = clock.GetUtcNow();
        var otp = await db.VerificationCodes.FirstOrDefaultAsync(o => o.Phone == phone);
        if (otp is null || otp.ExpiresAt < now)
            return AuthErrors.InvalidCode;
        if (otp.Attempts >= MaxAttempts)
            return AuthErrors.TooManyAttempts;

        var ok = CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(otp.CodeHash),
            Encoding.UTF8.GetBytes(HashCode(phone, code)));
        if (!ok)
        {
            otp.Attempts++;
            await db.SaveChangesAsync();
            return AuthErrors.InvalidCode;
        }

        db.VerificationCodes.Remove(otp);

        var user = await db.Customers.FirstOrDefaultAsync(u => u.Phone == phone);
        if (user is null)
        {
            user = new Customer { Phone = phone, Role = UserRole.Customer, CreatedAt = now };
            db.Customers.Add(user);
        }
        else if (!user.IsActive)
        {
            await db.SaveChangesAsync(); // the used code is still consumed
            return AuthErrors.AccountDeactivated;
        }

        var response = IssueTokens(user);
        await db.SaveChangesAsync();
        return response;
    }

    /// Staff login. The same error for "no such e-mail" and "wrong password",
    /// so nobody can probe which e-mails have accounts.
    public async Task<Result<AuthResponseDto>> StaffLoginAsync(string email, string password)
    {
        var normalized = email.Trim().ToLowerInvariant();
        var employee = await db.Employees
            .Include(e => e.Credentials)
            .FirstOrDefaultAsync(e => e.Email == normalized);
        if (employee?.Credentials is null ||
            !passwords.Verify(employee, employee.Credentials.PasswordHash, password))
            return AuthErrors.InvalidCredentials;
        if (!employee.IsActive) return AuthErrors.AccountDeactivated;

        var response = IssueTokens(employee);
        await db.SaveChangesAsync();
        return response;
    }

    /// Rotation: the old refresh token is revoked and a new pair is issued.
    public async Task<Result<AuthResponseDto>> RefreshAsync(string refreshToken)
    {
        var hash = TokenService.Hash(refreshToken);
        var stored = await db.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == hash);
        if (stored is null || stored.RevokedAt is not null || stored.ExpiresAt < clock.GetUtcNow()
            || !stored.User.IsActive)
            return AuthErrors.InvalidToken;

        stored.RevokedAt = clock.GetUtcNow();
        var response = IssueTokens(stored.User);
        await db.SaveChangesAsync();
        return response;
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
            // Only customers are asked for a name on first login.
            IsNew: user is Customer && string.IsNullOrWhiteSpace(user.Name));
    }

    // Phone is mixed in so equal codes for different phones have different hashes.
    private static string HashCode(string phone, string code) => TokenService.Hash($"{phone}:{code}");
}
