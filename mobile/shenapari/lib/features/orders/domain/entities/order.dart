import 'package:equatable/equatable.dart';
import 'package:shenapari_core/orders/order_status.dart';

export 'package:shenapari_core/orders/order_status.dart';

import '../../../menu/domain/entities/break_slot.dart';

/// Payment is simulated: the provider only says which button was used.
enum PaymentProvider { googlePay, applePay, unknown }

class OrderItem extends Equatable {
  const OrderItem({
    required this.dishId,
    required this.name,
    required this.quantity,
    required this.unitPriceKopecks,
  });

  final int dishId;

  /// As it was when ordered; the dish may be renamed later.
  final String name;
  final int quantity;
  final int unitPriceKopecks;

  @override
  List<Object?> get props => [dishId, name, quantity, unitPriceKopecks];
}

/// One step in the order's life: when it got [status], and why (for a
/// cancellation by the kitchen).
class OrderStatusChange extends Equatable {
  const OrderStatusChange({
    required this.status,
    required this.at,
    this.reason,
  });

  final OrderStatus status;
  final DateTime at;
  final String? reason;

  @override
  List<Object?> get props => [status, at, reason];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.totalKopecks,
    required this.createdAt,
    required this.items,
    this.breakSlot,
    this.estimatedReadyAt,
    this.readyAt,
    this.history = const [],
    this.pickupToken,
  });

  final String id;

  /// Short daily number the kitchen calls out: «№7».
  final int number;
  final OrderStatus status;

  /// What was charged, priced by the server.
  final int totalKopecks;
  final DateTime createdAt;
  final List<OrderItem> items;

  /// Null means «as soon as possible».
  final BreakSlot? breakSlot;

  /// Set when the kitchen accepts the order.
  final DateTime? estimatedReadyAt;

  /// When it became ready; pickup is possible for 30 minutes after.
  final DateTime? readyAt;

  /// Oldest first.
  final List<OrderStatusChange> history;

  /// What the QR encodes; the server sends it only while the order is ready.
  final String? pickupToken;

  /// Still on the kitchen's board.
  bool get isActive => switch (status) {
    OrderStatus.paid ||
    OrderStatus.accepted ||
    OrderStatus.cooking ||
    OrderStatus.ready => true,
    _ => false,
  };

  /// The customer may cancel until cooking starts (backend rule, shown here
  /// only to decide whether to offer the button; the server checks again).
  bool get canCancel =>
      status == OrderStatus.paid || status == OrderStatus.accepted;

  /// When this order got [status], if it ever did.
  DateTime? reachedAt(OrderStatus status) {
    for (final change in history.reversed) {
      if (change.status == status) return change.at;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    number,
    status,
    totalKopecks,
    createdAt,
    items,
    breakSlot,
    estimatedReadyAt,
    readyAt,
    history,
    pickupToken,
  ];
}
