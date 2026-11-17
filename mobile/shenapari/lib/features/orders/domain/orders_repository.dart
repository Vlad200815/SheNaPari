import '../../../core/result/result.dart';
import '../../cart/domain/entities/cart.dart';
import 'entities/order.dart';

abstract interface class OrdersRepository {
  /// Pays (simulated) and places the order in one go. [breakSlotId] null
  /// means «as soon as possible». The server prices it from its own menu.
  ///
  /// Codes to expect: `order.canteen_paused`, `order.break_passed`,
  /// `order.dish_unavailable`.
  Future<Result<Order>> placeOrder({
    required List<CartItem> items,
    required int? breakSlotId,
    required PaymentProvider provider,
  });
}
