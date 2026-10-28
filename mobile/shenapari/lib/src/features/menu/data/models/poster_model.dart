import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';

part "poster_model.g.dart";

@JsonSerializable()
class PosterModel {
  /// posterImage
  @JsonKey(name: "posterImage")
  final String? posterImage;

  /// urlLink
  @JsonKey(name: "urlLink")
  final String? urlLink;

  PosterModel({required this.posterImage, required this.urlLink});

  /// Deserializer...
  factory PosterModel.fromJson(Map<String, dynamic> json) =>
      _$PosterModelFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$PosterModelToJson(this);

  /// To Entity
  PosterEntity toEntity() =>
      PosterEntity(posterImage: posterImage, urlLink: urlLink);
}
