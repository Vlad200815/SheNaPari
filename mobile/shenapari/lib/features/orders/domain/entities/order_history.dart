import 'package:equatable/equatable.dart';

import 'order.dart';

/// A month of the history, for its header: how many orders and how much
/// money they took (cancelled ones are refunded, so they count as 0).
class OrderMonth extends Equatable {
  const OrderMonth({
    required this.year,
    required this.month,
    required this.count,
    required this.spentKopecks,
  });

  final int year;
  final int month;
  final int count;
  final int spentKopecks;

  @override
  List<Object?> get props => [year, month, count, spentKopecks];
}

/// One page of finished orders, newest first. [months] cover the whole
/// history under the same filter, not just this page.
class OrderHistoryPage extends Equatable {
  const OrderHistoryPage({
    required this.orders,
    required this.hasMore,
    required this.months,
  });

  final List<Order> orders;
  final bool hasMore;
  final List<OrderMonth> months;

  @override
  List<Object?> get props => [orders, hasMore, months];
}
