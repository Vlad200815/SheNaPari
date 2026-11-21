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

  /// Dishes that ran out since they were added: the order can't include
  /// them, so they are removed before checkout.
  bool get hasSoldOut => items.any((item) => !item.dish.isAvailable);

  Iterable<CartItem> get _orderable =>
      items.where((item) => item.dish.isAvailable);

  /// Portions that can be ordered, for the badge and the total.
  int get count => _orderable.fold(0, (sum, item) => sum + item.quantity);

  int get totalKopecks =>
      _orderable.fold(0, (sum, item) => sum + item.totalKopecks);

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
  /// the app's current language, current prices, sold out or not.
  /// [dishes] is the whole menu: a dish it no longer has was removed from
  /// the menu and counts as sold out.
  Cart withFreshDishes(Iterable<Dish> dishes) {
    final byId = {for (final dish in dishes) dish.id: dish};
    return Cart([
      for (final item in items)
        CartItem(
          dish: byId[item.dish.id] ?? item.dish.soldOut(),
          quantity: item.quantity,
        ),
    ]);
  }

  /// «Прибрати те, що закінчилось».
  Cart withoutSoldOut() => Cart([
    for (final item in items)
      if (item.dish.isAvailable) item,
  ]);

  Cart remove(int dishId) => Cart([
    for (final item in items)
      if (item.dish.id != dishId) item,
  ]);

  @override
  List<Object?> get props => [items];
}
