import 'package:equatable/equatable.dart';

import 'canteen.dart';
import 'category.dart';
import 'dish.dart';

/// Everything the home screen shows, loaded together.
class Menu extends Equatable {
  const Menu({
    required this.canteen,
    required this.categories,
    required this.dishes,
  });

  final Canteen canteen;

  /// Only categories that have at least one dish, in the server's order.
  final List<Category> categories;
  final List<Dish> dishes;

  bool get hasPopular => dishes.any((dish) => dish.isPopular);

  @override
  List<Object?> get props => [canteen, categories, dishes];
}
