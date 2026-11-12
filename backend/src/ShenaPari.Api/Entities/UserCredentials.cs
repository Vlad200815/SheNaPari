namespace ShenaPari.Api.Entities;

/// Password of an Employee, kept apart from the user row. Only a salted hash is stored.
public class UserCredentials
{
    public Guid UserId { get; set; }
    public required string PasswordHash { get; set; }
}
