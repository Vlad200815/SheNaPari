namespace ShenaPari.Api.Dtos;

public record OtpRequestDto(string Phone);

public record OtpVerifyDto(string Phone, string Code);

public record RefreshDto(string RefreshToken);

/// IsNew = the user has no name yet → the app shows the "enter your name" screen.
public record AuthResponseDto(string AccessToken, string RefreshToken, bool IsNew);

public record MeDto(Guid Id, string Phone, string? Name, string Role);

public record UpdateMeDto(string Name);
