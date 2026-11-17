import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/order_events.dart';
import '../../domain/orders_repository.dart';

part 'order_cubit.freezed.dart';

enum OrderLoadStatus { loading, loaded, failure }

@freezed
abstract class OrderState with _$OrderState {
  const factory OrderState({
    @Default(OrderLoadStatus.loading) OrderLoadStatus status,
    Order? order,
    @Default(false) bool cancelling,

    /// A failed refresh or cancellation; the order stays on screen.
    Failure? failure,
  }) = _OrderState;
}

/// One order, kept up to date: SignalR says "this order changed", the
/// cubit reloads it over REST (history, QR token and all).
class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._orders, this._events, {required this.orderId})
    : super(const OrderState());

  final OrdersRepository _orders;
  final OrderEvents _events;
  final String orderId;
  StreamSubscription<String?>? _live;

  Future<void> load() async {
    await _fetch();
    _live ??= _events.changes.listen((id) {
      if (id == null || id == orderId) _fetch();
    });
  }

  Future<void> refresh() => _fetch();

  Future<void> cancel() async {
    if (state.cancelling || !(state.order?.canCancel ?? false)) return;
    emit(state.copyWith(cancelling: true, failure: null));
    switch (await _orders.cancel(orderId)) {
      case Ok(value: final order):
        emit(state.copyWith(cancelling: false, order: order));
      case Err(:final failure):
        emit(state.copyWith(cancelling: false, failure: failure));
        // E.g. order.cannot_cancel: cooking started meanwhile.
        await _fetch();
    }
  }

  Future<void> _fetch() async {
    switch (await _orders.getOrder(orderId)) {
      case Ok(value: final order):
        emit(state.copyWith(status: OrderLoadStatus.loaded, order: order));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.order == null
                ? OrderLoadStatus.failure
                : OrderLoadStatus.loaded,
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
