import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari/src/features/auth/domain/entities/otp_entity.dart';

part "otp_response.g.dart";

@JsonSerializable()
class OtpResponse {
  /// message
  @JsonKey(name: "message")
  final String? message;

  /// expiresInSeconds
  @JsonKey(name: "expiresInSeconds")
  final int? expiresInSeconds;

  /// debugOtp
  @JsonKey(name: "debugOtp")
  final String? debugOtp;

  const OtpResponse({
    required this.message,
    required this.expiresInSeconds,
    required this.debugOtp,
  });

  /// Deserializer...
  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$OtpResponseToJson(this);

  /// From Data Model to Domain Entity
  OtpEntity toEntity() => OtpEntity(
    message: message,
    expiresInSeconds: expiresInSeconds,
    debugOtp: debugOtp,
  );
}
