import 'package:equatable/equatable.dart';

import '../../domain/entities/dish.dart';

/// Which dishes the home screen shows.
sealed class MenuFilter extends Equatable {
  const MenuFilter();

  bool matches(Dish dish) => switch (this) {
    AllDishes() => true,
    PopularDishes() => dish.isPopular,
    CategoryDishes(:final categoryId) => dish.categoryId == categoryId,
  };

  @override
  List<Object?> get props => [];
}

final class AllDishes extends MenuFilter {
  const AllDishes();
}

final class PopularDishes extends MenuFilter {
  const PopularDishes();
}

final class CategoryDishes extends MenuFilter {
  const CategoryDishes(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}
