import 'entities/cart.dart';

/// Keeps the cart on the phone between launches. No server involved.
abstract interface class CartRepository {
  /// An empty cart when nothing (or nothing readable) is stored.
  Cart load();

  Future<void> save(Cart cart);
}
