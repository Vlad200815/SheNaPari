namespace ShenaPari.Api.Entities;

/// One-time login code. Only a hash is stored, never the code itself.
public class OtpCode
{
    public Guid Id { get; set; }
    public required string Phone { get; set; }
    public required string CodeHash { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
    public int Attempts { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}
