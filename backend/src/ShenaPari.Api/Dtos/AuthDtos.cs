using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Dtos;

public record OtpRequestDto(string Phone);

public record OtpVerifyDto(string Phone, string Code);

public record StaffLoginDto(string Email, string Password);

public record RefreshDto(string RefreshToken);

/// IsNew = the user has no name yet → the app shows the "enter your name" screen.
public record AuthResponseDto(string AccessToken, string RefreshToken, bool IsNew);

/// Phone is set for customers, Email for employees.
public record MeDto(Guid Id, UserRole Role, string? Name, string? Phone, string? Email);

public record UpdateMeDto(string Name);
