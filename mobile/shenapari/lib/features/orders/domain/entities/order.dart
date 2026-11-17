import 'package:equatable/equatable.dart';

import '../../../menu/domain/entities/break_slot.dart';

/// Paid → Accepted → Cooking → Ready → PickedUp; Cancelled before cooking,
/// NotPickedUp when nobody came for a ready order.
enum OrderStatus {
  paid,
  accepted,
  cooking,
  ready,
  pickedUp,
  cancelled,
  notPickedUp,
  unknown,
}

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
  ];
}
