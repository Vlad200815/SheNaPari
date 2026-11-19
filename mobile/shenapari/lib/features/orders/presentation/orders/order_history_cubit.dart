import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_history.dart';
import '../../domain/order_events.dart';
import '../../domain/orders_repository.dart';

part 'order_history_cubit.freezed.dart';

/// `failure` only when the first page could not be loaded; a failed refresh
/// or next page keeps what is shown and just sets [OrderHistoryState.failure].
enum OrderHistoryStatus { loading, loaded, failure }

@freezed
abstract class OrderHistoryState with _$OrderHistoryState {
  const factory OrderHistoryState({
    @Default(OrderHistoryStatus.loading) OrderHistoryStatus status,

    /// Null: every finished order; otherwise picked up, cancelled or not
    /// picked up only.
    OrderStatus? filter,
    @Default(<Order>[]) List<Order> orders,
    @Default(<OrderMonth>[]) List<OrderMonth> months,
    @Default(false) bool hasMore,
    @Default(false) bool loadingMore,
    Failure? failure,
  }) = _OrderHistoryState;
}

/// The history tab: finished orders a page at a time, with a filter.
class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._orders, this._events)
    : super(const OrderHistoryState());

  final OrdersRepository _orders;
  final OrderEvents _events;
  StreamSubscription<String?>? _live;

  /// Bumped by every first-page load, so an answer for an old filter that
  /// arrives late is dropped.
  int _generation = 0;

  Future<void> load() async {
    emit(state.copyWith(status: OrderHistoryStatus.loading, failure: null));
    await _firstPage();
    // A finished order (picked up, cancelled) moves here: reload then.
    _live ??= _events.changes.listen((_) => refresh());
  }

  /// Pull-to-refresh: the list stays on screen while loading.
  Future<void> refresh() async {
    if (state.status != OrderHistoryStatus.loaded) return load();
    emit(state.copyWith(failure: null));
    await _firstPage();
  }

  Future<void> setFilter(OrderStatus? filter) async {
    if (filter == state.filter) return;
    emit(
      state.copyWith(
        filter: filter,
        status: OrderHistoryStatus.loading,
        orders: const [],
        months: const [],
        hasMore: false,
        loadingMore: false,
        failure: null,
      ),
    );
    await _firstPage();
  }

  /// The next page, when the list is scrolled near its end.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.loadingMore ||
        state.status != OrderHistoryStatus.loaded) {
      return;
    }
    final generation = _generation;
    emit(state.copyWith(loadingMore: true, failure: null));
    final result = await _orders.getHistory(
      status: state.filter,
      before: state.orders.last.createdAt,
    );
    if (generation != _generation || isClosed) return;
    switch (result) {
      case Ok(value: final page):
        emit(
          state.copyWith(
            orders: [...state.orders, ...page.orders],
            months: page.months,
            hasMore: page.hasMore,
            loadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(loadingMore: false, failure: failure));
    }
  }

  Future<void> _firstPage() async {
    final generation = ++_generation;
    final result = await _orders.getHistory(status: state.filter);
    if (generation != _generation || isClosed) return;
    switch (result) {
      case Ok(value: final page):
        emit(
          state.copyWith(
            status: OrderHistoryStatus.loaded,
            orders: page.orders,
            months: page.months,
            hasMore: page.hasMore,
            loadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.status == OrderHistoryStatus.loaded
                ? OrderHistoryStatus.loaded
                : OrderHistoryStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _live?.cancel();
    return super.close();
  }
}
