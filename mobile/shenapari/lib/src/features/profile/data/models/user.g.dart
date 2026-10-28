// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
  role: json['role'] as String?,
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'fullName': instance.fullName,
  'role': instance.role,
  'loyaltyPoints': instance.loyaltyPoints,
};
