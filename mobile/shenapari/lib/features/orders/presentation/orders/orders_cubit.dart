import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
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

  List<Order> get active => [
    for (final o in orders)
      if (o.isActive) o,
  ];
  List<Order> get past => [
    for (final o in orders)
      if (!o.isActive) o,
  ];

  /// What «Мій QR» shows: a ready order first, else the oldest active one
  /// (the one the kitchen will finish first).
  Order? get forPickup {
    for (final order in active) {
      if (order.status == OrderStatus.ready) return order;
    }
    return active.isEmpty ? null : active.last;
  }
}

/// The customer's orders; reloads by itself when the kitchen changes a
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
    switch (await _orders.getMyOrders()) {
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
