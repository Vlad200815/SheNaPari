import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

import '../domain/entities/kitchen_order.dart';

part 'queue_state.freezed.dart';

enum QueueStatus { loading, loaded, failure }

/// The chips over the columns: everything, only «as soon as possible», or
/// one break.
sealed class QueueFilter extends Equatable {
  const QueueFilter();

  bool matches(KitchenOrder order);
}

final class AllOrders extends QueueFilter {
  const AllOrders();

  @override
  bool matches(KitchenOrder order) => true;

  @override
  List<Object?> get props => [];
}

final class AsapOrders extends QueueFilter {
  const AsapOrders();

  @override
  bool matches(KitchenOrder order) => order.isAsap;

  @override
  List<Object?> get props => [];
}

final class BreakOrders extends QueueFilter {
  const BreakOrders(this.startsAt);

  final DateTime startsAt;

  @override
  bool matches(KitchenOrder order) => order.breakStartsAt == startsAt;

  @override
  List<Object?> get props => [startsAt];
}

@freezed
abstract class QueueState with _$QueueState {
  const QueueState._();

  const factory QueueState({
    @Default(QueueStatus.loading) QueueStatus status,
    @Default(<KitchenOrder>[]) List<KitchenOrder> orders,
    @Default(AllOrders()) QueueFilter filter,

    /// Orders with a request in flight: their buttons show a spinner.
    @Default(<String>{}) Set<String> busy,

    /// The latest new orders' numbers, for the toast; [arrivals] counts
    /// them, so the same number twice still shows a toast.
    @Default(<int>[]) List<int> arrived,
    @Default(0) int arrivals,

    /// «Now» for the timers («ще 7 хв», «+3 хв»), ticked by the cubit.
    required DateTime now,
    Failure? failure,
  }) = _QueueState;

  /// One column, filtered, the one needed soonest on top.
  List<KitchenOrder> column(QueueColumn column) => [
    for (final order in orders)
      if (order.column == column && filter.matches(order)) order,
  ]..sort(_byNeed);

  int count(QueueColumn column) =>
      orders.where((o) => o.column == column).length;

  int get asapCount => orders.where((o) => o.isAsap).length;

  /// Today's breaks that have orders, soonest first, with their counts.
  List<(DateTime, int)> get breaks {
    final counts = <DateTime, int>{};
    for (final order in orders) {
      final start = order.breakStartsAt;
      if (start != null) counts[start] = (counts[start] ?? 0) + 1;
    }
    return [for (final e in counts.entries) (e.key, e.value)]
      ..sort((a, b) => a.$1.compareTo(b.$1));
  }

  static int _byNeed(KitchenOrder a, KitchenOrder b) {
    final byTime = a.neededBy.compareTo(b.neededBy);
    return byTime != 0 ? byTime : a.number.compareTo(b.number);
  }
}
