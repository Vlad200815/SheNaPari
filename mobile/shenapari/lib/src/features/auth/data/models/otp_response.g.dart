// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpResponse _$OtpResponseFromJson(Map<String, dynamic> json) => OtpResponse(
  message: json['message'] as String?,
  expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
  debugOtp: json['debugOtp'] as String?,
);

Map<String, dynamic> _$OtpResponseToJson(OtpResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'expiresInSeconds': instance.expiresInSeconds,
      'debugOtp': instance.debugOtp,
    };
