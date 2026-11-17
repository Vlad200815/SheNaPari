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
  ];
}
