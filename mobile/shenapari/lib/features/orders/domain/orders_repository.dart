import 'package:shenapari_core/result/result.dart';
import '../../cart/domain/entities/cart.dart';
import 'entities/order.dart';
import 'entities/order_history.dart';

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

  /// The orders still in work (paid … ready), newest first.
  Future<Result<List<Order>>> getActiveOrders();

  /// Finished orders, newest first, a page at a time: the next page starts
  /// [before] the `createdAt` of the last order shown. [status] narrows it
  /// to picked up, cancelled or not picked up; null means all of them.
  Future<Result<OrderHistoryPage>> getHistory({
    OrderStatus? status,
    DateTime? before,
  });

  Future<Result<Order>> getOrder(String id);

  /// Until cooking starts; later `order.cannot_cancel` (409).
  Future<Result<Order>> cancel(String id);
}
