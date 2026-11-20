import 'package:shenapari_core/result/result.dart';

import 'entities/kitchen_order.dart';

abstract interface class QueueRepository {
  /// Orders still in work: paid, accepted, cooking, ready (today's breaks
  /// and «as soon as possible»).
  Future<Result<List<KitchenOrder>>> getQueue();

  /// «Прийняти»: ready in [minutes] (5, 10, 15 or 20), then straight to
  /// cooking — one tap in the kitchen; the customer still sees both steps.
  Future<Result<void>> accept(String id, {required int minutes});

  /// Cooking → ready, or ready → picked up («Видати без QR»).
  Future<Result<void>> setStatus(String id, OrderStatus status);
}
