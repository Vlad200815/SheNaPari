namespace ShenaPari.Api.Entities;

/// Students and canteen staff live in one table; Role tells them apart.
public class User
{
    public Guid Id { get; set; }
    public required string Phone { get; set; }
    public string? Name { get; set; }
    public UserRole Role { get; set; } = UserRole.Student;
    public DateTimeOffset CreatedAt { get; set; }

    public List<Order> Orders { get; set; } = [];
}
