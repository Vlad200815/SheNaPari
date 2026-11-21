import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/stop_list_dish.dart';

part 'stop_list_dtos.g.dart';

/// Backend `StaffDishDto`.
@JsonSerializable(createToJson: false)
class StaffDishDto {
  const StaffDishDto({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.isAvailable,
  });

  factory StaffDishDto.fromJson(Map<String, dynamic> json) =>
      _$StaffDishDtoFromJson(json);

  final int id;
  final int categoryId;
  final String name;
  final bool isAvailable;

  StopListDish toEntity() => StopListDish(
    id: id,
    categoryId: categoryId,
    name: name,
    isAvailable: isAvailable,
  );
}

/// Backend `CategoryDto` (`GET /categories`).
@JsonSerializable(createToJson: false)
class CategoryDto {
  const CategoryDto({required this.id, required this.name});

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  final int id;
  final String name;

  DishCategory toEntity() => DishCategory(id: id, name: name);
}

@JsonSerializable(createFactory: false)
class SetAvailabilityDto {
  const SetAvailabilityDto({required this.isAvailable});

  final bool isAvailable;

  Map<String, dynamic> toJson() => _$SetAvailabilityDtoToJson(this);
}
