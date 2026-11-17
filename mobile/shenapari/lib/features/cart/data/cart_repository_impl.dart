import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/domain/entities/dish.dart';
import '../domain/cart_repository.dart';
import '../domain/entities/cart.dart';

/// The cart as JSON in SharedPreferences. Not secret, small, and losing it
/// is harmless, so no secure storage or database is needed.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'cart';

  @override
  Cart load() {
    final json = _prefs.getString(_key);
    if (json == null) return const Cart();
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return Cart([
        for (final item in list.cast<Map<String, dynamic>>()) _fromJson(item),
      ]);
    } on Object {
      return const Cart(); // An old or broken format: start over.
    }
  }

  @override
  Future<void> save(Cart cart) => _prefs.setString(
    _key,
    jsonEncode([for (final item in cart.items) _toJson(item)]),
  );

  static Map<String, dynamic> _toJson(CartItem item) => {
    'quantity': item.quantity,
    'id': item.dish.id,
    'categoryId': item.dish.categoryId,
    'name': item.dish.name,
    'description': item.dish.description,
    'priceKopecks': item.dish.priceKopecks,
    'weightG': item.dish.weightG,
    'kcal': item.dish.kcal,
    'imageUrl': item.dish.imageUrl,
    'isPopular': item.dish.isPopular,
  };

  static CartItem _fromJson(Map<String, dynamic> json) => CartItem(
    quantity: json['quantity'] as int,
    dish: Dish(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceKopecks: json['priceKopecks'] as int,
      weightG: json['weightG'] as int,
      kcal: json['kcal'] as int,
      imageUrl: json['imageUrl'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
    ),
  );
}
