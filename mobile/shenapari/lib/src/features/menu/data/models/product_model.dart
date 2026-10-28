import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/entities.dart';

part "product_model.g.dart";

@JsonSerializable()
class ProductModel {
  /// image
  @JsonKey(name: "image")
  final String? image;

  /// rating
  @JsonKey(name: "rating")
  final double? rating;

  /// title
  @JsonKey(name: "title")
  final String? title;

  /// price
  @JsonKey(name: "price")
  final double? price;

  /// id
  @JsonKey(name: "id")
  final String? id;

  const ProductModel({
    required this.image,
    required this.rating,
    required this.title,
    required this.price,
    required this.id,
  });

  /// Deserializer...
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  /// To Entity
  ProductEntity toEntity() => ProductEntity(
    image: image,
    rating: rating,
    title: title,
    price: price,
    id: id,
  );
}
