using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Dtos;

public record OtpRequestDto(string Phone);

public record OtpVerifyDto(string Phone, string Code);

public record StaffLoginDto(string Email, string Password);

public record RefreshDto(string RefreshToken);

/// IsNew = the user has no name yet → the app shows the "enter your name" screen.
public record AuthResponseDto(string AccessToken, string RefreshToken, bool IsNew);

/// Phone is set for customers, Email for employees.
/// OrderPushEnabled is null for staff (they get no order pushes).
public record MeDto(Guid Id, UserRole Role, string? Name, string? Phone, string? Email, bool? OrderPushEnabled);

public record UpdateMeDto(string Name);

/// PUT /me/settings
public record MeSettingsDto(bool OrderPushEnabled);

/// Token = the Firebase device token; null switches notifications off for this device.
public record PushTokenDto(string? Token);

/// An item of GET /me/notifications.
public record NotificationDto(Guid Id, Guid? OrderId, string Title, string Body, DateTimeOffset CreatedAt, bool IsRead);
