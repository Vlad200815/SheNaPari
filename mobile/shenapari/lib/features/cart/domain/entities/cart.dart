import 'package:equatable/equatable.dart';

import '../../../menu/domain/entities/dish.dart';

class CartItem extends Equatable {
  const CartItem({required this.dish, required this.quantity});

  /// A snapshot taken when the dish was added. The server prices the order
  /// itself at checkout, so a stale price here can never be charged.
  final Dish dish;
  final int quantity;

  int get totalKopecks => dish.priceKopecks * quantity;

  @override
  List<Object?> get props => [dish, quantity];
}

/// The local cart: lives on the phone until the order is placed.
class Cart extends Equatable {
  const Cart([this.items = const []]);

  /// The server accepts 1–20 of one dish (`order.invalid_quantity`); the
  /// stepper needs a limit anyway, so it uses the same one.
  static const maxQuantity = 20;

  /// In the order the dishes were first added.
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  /// Number of portions, for the badge on the tab bar.
  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalKopecks => items.fold(0, (sum, item) => sum + item.totalKopecks);

  int quantityOf(int dishId) {
    for (final item in items) {
      if (item.dish.id == dishId) return item.quantity;
    }
    return 0;
  }

  /// Adds [quantity] portions (up to [maxQuantity] in total).
  Cart add(Dish dish, {int quantity = 1}) =>
      setQuantity(dish, quantityOf(dish.id) + quantity);

  /// Sets the portions of [dish]; 0 or less removes it.
  Cart setQuantity(Dish dish, int quantity) {
    final clamped = quantity.clamp(0, maxQuantity);
    final exists = items.any((item) => item.dish.id == dish.id);
    if (!exists) {
      return clamped == 0
          ? this
          : Cart([...items, CartItem(dish: dish, quantity: clamped)]);
    }
    return Cart([
      for (final item in items)
        if (item.dish.id != dish.id)
          item
        else if (clamped > 0)
          CartItem(dish: item.dish, quantity: clamped),
    ]);
  }

  /// The same portions with the dishes as the menu shows them now: names in
  /// the app's current language, current prices. A dish the menu no longer
  /// has keeps its copy (the server says so at checkout).
  Cart withFreshDishes(Iterable<Dish> dishes) {
    final byId = {for (final dish in dishes) dish.id: dish};
    return Cart([
      for (final item in items)
        CartItem(
          dish: byId[item.dish.id] ?? item.dish,
          quantity: item.quantity,
        ),
    ]);
  }

  Cart remove(int dishId) => Cart([
    for (final item in items)
      if (item.dish.id != dishId) item,
  ]);

  @override
  List<Object?> get props => [items];
}
