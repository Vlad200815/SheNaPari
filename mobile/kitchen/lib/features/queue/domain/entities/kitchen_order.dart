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

/// One step of the order's history: when it moved and why (a reason only
/// for a kitchen cancellation).
class KitchenOrderStep extends Equatable {
  const KitchenOrderStep({required this.status, required this.at, this.reason});

  final OrderStatus status;
  final DateTime at;
  final String? reason;

  @override
  List<Object?> get props => [status, at, reason];
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
    this.totalKopecks = 0,
    this.history = const [],
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
  final int totalKopecks;

  /// Oldest first.
  final List<KitchenOrderStep> history;

  /// The kitchen may stop it until it is ready (it ran out of something).
  bool get canCancel =>
      status == OrderStatus.paid ||
      status == OrderStatus.accepted ||
      status == OrderStatus.cooking;

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
    totalKopecks,
    history,
  ];
}
