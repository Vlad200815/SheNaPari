// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpError _$HttpErrorFromJson(Map<String, dynamic> json) => HttpError(
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  details: (json['details'] as List<dynamic>?)
      ?.map((e) => HttpDetailsError.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HttpErrorToJson(HttpError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': instance.details,
};

HttpDetailsError _$HttpDetailsErrorFromJson(Map<String, dynamic> json) =>
    HttpDetailsError(
      type: json['@type'] as String?,
      additionalProp1: json['additionalProp1'] as String?,
      additionalProp2: json['additionalProp2'] as String?,
      additionalProp3: json['additionalProp3'] as String?,
    );

Map<String, dynamic> _$HttpDetailsErrorToJson(HttpDetailsError instance) =>
    <String, dynamic>{
      '@type': instance.type,
      'additionalProp1': instance.additionalProp1,
      'additionalProp2': instance.additionalProp2,
      'additionalProp3': instance.additionalProp3,
    };
