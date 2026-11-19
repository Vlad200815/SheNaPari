import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/break_slot.dart';
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

/// `GET /breaks/next`
@JsonSerializable(createToJson: false)
class BreakSlotDto {
  const BreakSlotDto({
    required this.id,
    required this.startsAt,
    required this.endsAt,
  });

  factory BreakSlotDto.fromJson(Map<String, dynamic> json) =>
      _$BreakSlotDtoFromJson(json);

  final int id;

  /// ISO 8601 with an offset, e.g. `2026-11-17T11:40:00+00:00`.
  final DateTime startsAt;
  final DateTime endsAt;

  BreakSlot toEntity() =>
      BreakSlot(id: id, startsAt: startsAt.toLocal(), endsAt: endsAt.toLocal());
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
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.spicyLevel = 0,
    this.isVegan = false,
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
  final int? proteinG;
  final int? fatG;
  final int? carbsG;
  final int spicyLevel;
  final bool isVegan;

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
    proteinG: proteinG,
    fatG: fatG,
    carbsG: carbsG,
    spicyLevel: spicyLevel.clamp(0, 3),
    isVegan: isVegan,
  );
}
