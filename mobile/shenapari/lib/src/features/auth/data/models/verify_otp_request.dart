import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part "verify_otp_request.g.dart";

@JsonSerializable()
class VerifyOtpRequest extends Equatable {
  /// phone
  @JsonKey(name: "phone")
  final String phone;

  /// otp_code
  @JsonKey(name: "code")
  final String otpCode;

  /// fcmToken
  @JsonKey(name: "fcmToken")
  final String fcmToken;

  const VerifyOtpRequest({
    required this.phone,
    required this.otpCode,
    required this.fcmToken,
  });

  /// Deserializer...
  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);

  @override
  List<Object?> get props => [phone, otpCode, fcmToken];
}
