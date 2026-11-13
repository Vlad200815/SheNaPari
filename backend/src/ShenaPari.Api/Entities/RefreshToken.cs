namespace ShenaPari.Api.Entities;

/// One login session on one device. The token itself is stored as a hash.
/// RevokedAt != null means logged out or rotated.
public class RefreshToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public required string TokenHash { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
    public DateTimeOffset? RevokedAt { get; set; }

    /// Firebase device token of the phone this session lives on (for push notifications).
    public string? PushToken { get; set; }
}
