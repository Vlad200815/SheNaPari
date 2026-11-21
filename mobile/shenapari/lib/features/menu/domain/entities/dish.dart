import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  const Dish({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.priceKopecks,
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
    this.isAvailable = true,
  });

  final int id;
  final int categoryId;
  final String name;
  final String? description;

  /// The price in kopecks: whole numbers add up exactly in the cart,
  /// unlike `double` (0.1 + 0.2 != 0.3).
  final int priceKopecks;
  final int weightG;
  final int kcal;

  /// A full URL ready for `Image.network`, or null when there is no photo.
  final String? imageUrl;
  final bool isPopular;

  /// Grams per portion; null until the kitchen fills them in.
  final int? proteinG;
  final int? fatG;
  final int? carbsG;

  /// 0 not spicy … 3 very spicy.
  final int spicyLevel;
  final bool isVegan;

  /// False while the dish is on the kitchen's stop list («закінчилось»):
  /// shown greyed out, can't be ordered.
  final bool isAvailable;

  /// The same dish, sold out.
  Dish soldOut() => Dish(
    id: id,
    categoryId: categoryId,
    name: name,
    description: description,
    priceKopecks: priceKopecks,
    weightG: weightG,
    kcal: kcal,
    imageUrl: imageUrl,
    isPopular: isPopular,
    proteinG: proteinG,
    fatG: fatG,
    carbsG: carbsG,
    spicyLevel: spicyLevel,
    isVegan: isVegan,
    isAvailable: false,
  );

  bool get hasMacros => proteinG != null && fatG != null && carbsG != null;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    description,
    priceKopecks,
    weightG,
    kcal,
    imageUrl,
    isPopular,
    proteinG,
    fatG,
    carbsG,
    isAvailable,
    spicyLevel,
    isVegan,
  ];
}
