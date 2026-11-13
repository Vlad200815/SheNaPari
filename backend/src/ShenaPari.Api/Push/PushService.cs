using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Data;

namespace ShenaPari.Api.Push;

/// Knows which devices belong to a user. A device token lives on the login session
/// (RefreshToken row), so logging out stops notifications for that device.
public class PushService(AppDbContext db, IPushSender sender, TimeProvider clock, ILogger<PushService> logger)
{
    /// Called by the app after login and whenever Firebase gives it a new token.
    public async Task SetDeviceTokenAsync(Guid sessionId, string? deviceToken)
    {
        deviceToken = string.IsNullOrWhiteSpace(deviceToken) ? null : deviceToken.Trim();
        if (deviceToken is not null)
        {
            // One phone = one account: if someone else was logged in on this phone before,
            // their session must stop getting this phone's notifications.
            await db.RefreshTokens
                .Where(t => t.PushToken == deviceToken && t.Id != sessionId)
                .ExecuteUpdateAsync(s => s.SetProperty(t => t.PushToken, (string?)null));
        }
        await db.RefreshTokens
            .Where(t => t.Id == sessionId)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.PushToken, deviceToken));
    }

    /// Sends to all devices where the user is logged in. Never throws:
    /// a failed notification must not break the order flow.
    public async Task SendToUserAsync(Guid userId, PushMessage message)
    {
        try
        {
            var now = clock.GetUtcNow();
            var tokens = await db.RefreshTokens
                .Where(t => t.UserId == userId && t.RevokedAt == null && t.ExpiresAt > now && t.PushToken != null)
                .Select(t => t.PushToken!)
                .Distinct()
                .ToListAsync();
            if (tokens.Count == 0) return;

            var dead = await sender.SendAsync(tokens, message);
            if (dead.Count > 0)
            {
                await db.RefreshTokens
                    .Where(t => t.PushToken != null && dead.Contains(t.PushToken))
                    .ExecuteUpdateAsync(s => s.SetProperty(t => t.PushToken, (string?)null));
            }
        }
        catch (Exception e)
        {
            logger.LogError(e, "Push to user {UserId} failed", userId);
        }
    }
}
