// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      phone: json['phone'] as String,
      otpCode: json['code'] as String,
      fcmToken: json['fcmToken'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'code': instance.otpCode,
      'fcmToken': instance.fcmToken,
    };
