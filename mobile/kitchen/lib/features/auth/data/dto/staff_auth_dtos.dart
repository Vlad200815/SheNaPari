import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari_core/session/auth_tokens.dart';

part 'staff_auth_dtos.g.dart';

/// `POST /auth/staff/login`
@JsonSerializable(createFactory: false)
class StaffLoginDto {
  const StaffLoginDto({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$StaffLoginDtoToJson(this);
}

/// `POST /auth/logout`
@JsonSerializable(createFactory: false)
class RefreshDto {
  const RefreshDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshDtoToJson(this);
}

/// `data` of `/auth/staff/login` (backend `AuthResponseDto`; `isNew` is
/// always false for staff, so it is not read).
@JsonSerializable(createToJson: false)
class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  final String accessToken;
  final String refreshToken;

  AuthTokens toEntity() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}
