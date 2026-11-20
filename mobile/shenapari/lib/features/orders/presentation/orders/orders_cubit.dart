import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/order_events.dart';
import '../../domain/orders_repository.dart';

part 'orders_cubit.freezed.dart';

/// `failure` only when nothing could be loaded at all; a failed refresh
/// keeps the list and just sets [OrdersState.failure].
enum OrdersStatus { loading, loaded, failure }

@freezed
abstract class OrdersState with _$OrdersState {
  const OrdersState._();

  const factory OrdersState({
    @Default(OrdersStatus.loading) OrdersStatus status,
    @Default(<Order>[]) List<Order> orders,
    Failure? failure,
  }) = _OrdersState;

  /// [orders] come active from the server; one that the kitchen has just
  /// finished stays out of the list until the next reload.
  List<Order> get active => [
    for (final o in orders)
      if (o.isActive) o,
  ];

  /// What «Мій QR» shows, in order: ready orders first (the one that has
  /// waited longest at the top), then the rest, oldest first — the kitchen
  /// finishes those first.
  List<Order> get forPickup {
    DateTime readySince(Order o) =>
        o.readyAt ?? o.reachedAt(OrderStatus.ready) ?? o.createdAt;
    // List.sort is not stable: the order number breaks ties, so the cards
    // never swap places between reloads.
    int by(DateTime Function(Order) time, Order a, Order b) {
      final byTime = time(a).compareTo(time(b));
      return byTime != 0 ? byTime : a.number.compareTo(b.number);
    }

    final ready = [
      for (final o in active)
        if (o.status == OrderStatus.ready) o,
    ]..sort((a, b) => by(readySince, a, b));
    final waiting = [
      for (final o in active)
        if (o.status != OrderStatus.ready) o,
    ]..sort((a, b) => by((o) => o.createdAt, a, b));
    return [...ready, ...waiting];
  }

  int get readyCount => [
    for (final o in active)
      if (o.status == OrderStatus.ready) o,
  ].length;
}

/// The customer's active orders (the orders tab, «Мій QR», the glow on the
/// QR button); the history has its own [OrderHistoryCubit]. Reloads by itself when the kitchen changes a
/// status (SignalR).
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._orders, this._events) : super(const OrdersState());

  final OrdersRepository _orders;
  final OrderEvents _events;
  StreamSubscription<String?>? _live;

  Future<void> load() async {
    emit(state.copyWith(status: OrdersStatus.loading, failure: null));
    await _fetch();
    // Listen only after the first REST call: it refreshes the token the
    // live connection uses.
    _live ??= _events.changes.listen((_) => refresh());
  }

  Future<void> refresh() async {
    if (state.status != OrdersStatus.loaded) return load();
    emit(state.copyWith(failure: null));
    await _fetch();
  }

  Future<void> _fetch() async {
    switch (await _orders.getActiveOrders()) {
      case Ok(value: final orders):
        emit(state.copyWith(status: OrdersStatus.loaded, orders: orders));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.status == OrdersStatus.loaded
                ? OrdersStatus.loaded
                : OrdersStatus.failure,
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
