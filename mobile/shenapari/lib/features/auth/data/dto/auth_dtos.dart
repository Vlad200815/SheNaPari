import 'package:json_annotation/json_annotation.dart';

import '../../../../core/session/auth_tokens.dart';
import '../../domain/entities/sign_in.dart';

part 'auth_dtos.g.dart';

/// `POST /auth/otp/request`
@JsonSerializable(createFactory: false)
class OtpRequestDto {
  const OtpRequestDto({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => _$OtpRequestDtoToJson(this);
}

/// `POST /auth/otp/verify`
@JsonSerializable(createFactory: false)
class OtpVerifyDto {
  const OtpVerifyDto({required this.phone, required this.code});

  final String phone;
  final String code;

  Map<String, dynamic> toJson() => _$OtpVerifyDtoToJson(this);
}

/// `POST /auth/logout`
@JsonSerializable(createFactory: false)
class RefreshDto {
  const RefreshDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshDtoToJson(this);
}

/// `data` of `/auth/otp/verify` (backend `AuthResponseDto`).
@JsonSerializable(createToJson: false)
class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.isNew,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  final String accessToken;
  final String refreshToken;
  final bool isNew;

  SignIn toEntity() => SignIn(
    tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
    isNewUser: isNew,
  );
}
