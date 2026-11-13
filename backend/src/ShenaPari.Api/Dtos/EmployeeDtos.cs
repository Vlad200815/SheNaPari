using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Dtos;

public record EmployeeDto(Guid Id, string Email, string? Name, UserRole Role, bool IsActive, DateTimeOffset CreatedAt);

public record CreateEmployeeDto(string Email, string Password, string Name, UserRole Role);

public record SetPasswordDto(string Password);
