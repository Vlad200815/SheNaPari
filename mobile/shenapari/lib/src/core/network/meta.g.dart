// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  (json['page'] as num?)?.toInt(),
  (json['limit'] as num?)?.toInt(),
  (json['count'] as num?)?.toInt(),
  json['count_formatted'] as String?,
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'count': instance.count,
  'count_formatted': instance.countFormatted,
};
