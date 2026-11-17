import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/canteen.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/dish.dart';

part 'menu_dtos.g.dart';

/// `GET /canteen`
@JsonSerializable(createToJson: false)
class CanteenDto {
  const CanteenDto({required this.name, required this.isAcceptingOrders});

  factory CanteenDto.fromJson(Map<String, dynamic> json) =>
      _$CanteenDtoFromJson(json);

  final String name;
  final bool isAcceptingOrders;

  Canteen toEntity() =>
      Canteen(name: name, isAcceptingOrders: isAcceptingOrders);
}

/// An item of `GET /categories`.
@JsonSerializable(createToJson: false)
class CategoryDto {
  const CategoryDto({required this.id, required this.name});

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  final int id;
  final String name;

  Category toEntity() => Category(id: id, name: name);
}

/// An item of `GET /dishes`.
@JsonSerializable(createToJson: false)
class DishDto {
  const DishDto({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.weightG,
    required this.kcal,
    this.description,
    this.imageUrl,
    this.isPopular = false,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) =>
      _$DishDtoFromJson(json);

  final int id;
  final int categoryId;
  final String name;
  final String? description;

  /// `decimal` on the server: `85` or `42.5` in JSON.
  final num price;
  final int weightG;
  final int kcal;

  /// Relative to the server (`/images/dishes/5-ab12.jpg`) or null.
  final String? imageUrl;
  final bool isPopular;

  /// [baseUrl] is the server address the relative [imageUrl] belongs to.
  Dish toEntity({required String baseUrl}) => Dish(
    id: id,
    categoryId: categoryId,
    name: name,
    description: description,
    priceKopecks: (price * 100).round(),
    weightG: weightG,
    kcal: kcal,
    imageUrl: imageUrl == null
        ? null
        : Uri.parse(baseUrl).resolve(imageUrl!).toString(),
    isPopular: isPopular,
  );
}
