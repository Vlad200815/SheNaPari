import 'package:equatable/equatable.dart';
import 'package:shenapari_core/orders/order_status.dart';

export 'package:shenapari_core/orders/order_status.dart';

/// The three columns of the queue.
enum QueueColumn { fresh, cooking, ready }

class KitchenOrderItem extends Equatable {
  const KitchenOrderItem({required this.name, required this.quantity});

  final String name;
  final int quantity;

  @override
  List<Object?> get props => [name, quantity];
}

/// An order as the kitchen sees it (backend `StaffOrderDto`).
class KitchenOrder extends Equatable {
  const KitchenOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.createdAt,
    required this.items,
    this.customerName,
    this.breakStartsAt,
    this.estimatedReadyAt,
    this.readyAt,
  });

  final String id;

  /// Restarts every day: «№42».
  final int number;
  final OrderStatus status;
  final String? customerName;
  final DateTime createdAt;

  /// Null: «якнайшвидше».
  final DateTime? breakStartsAt;
  final DateTime? estimatedReadyAt;
  final DateTime? readyAt;
  final List<KitchenOrderItem> items;

  bool get isAsap => breakStartsAt == null;

  /// When the customer needs it: «as soon as possible» means now (it was
  /// needed from the moment it was paid), a break means its start. The
  /// queue sorts by this, so ASAP orders are always on top.
  DateTime get neededBy => breakStartsAt ?? createdAt;

  QueueColumn? get column => switch (status) {
    OrderStatus.paid => QueueColumn.fresh,
    OrderStatus.accepted || OrderStatus.cooking => QueueColumn.cooking,
    OrderStatus.ready => QueueColumn.ready,
    _ => null,
  };

  @override
  List<Object?> get props => [
    id,
    number,
    status,
    customerName,
    createdAt,
    breakStartsAt,
    estimatedReadyAt,
    readyAt,
    items,
  ];
}
