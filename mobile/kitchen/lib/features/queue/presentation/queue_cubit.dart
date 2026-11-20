import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/orders/order_events.dart';
import 'package:shenapari_core/result/result.dart';

import '../../../core/device/new_order_alert.dart';
import '../domain/entities/kitchen_order.dart';
import '../domain/queue_repository.dart';
import 'queue_state.dart';

/// The kitchen board. Reloads by itself on every order event (SignalR),
/// chimes for each new order, and ticks the timers every 30 s.
class QueueCubit extends Cubit<QueueState> {
  QueueCubit(
    this._queue,
    this._events,
    this._alert, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(QueueState(now: (clock ?? DateTime.now)()));

  final QueueRepository _queue;
  final OrderEvents _events;
  final NewOrderAlert _alert;
  final DateTime Function() _clock;
  StreamSubscription<String?>? _live;
  Timer? _tick;
  Timer? _debounce;

  static const tickEvery = Duration(seconds: 30);

  /// Events come in bursts (accept + cooking): one reload for them all.
  static const debounce = Duration(milliseconds: 300);

  Future<void> load() async {
    emit(state.copyWith(status: QueueStatus.loading, failure: null));
    await _fetch();
    _live ??= _events.changes.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(debounce, refresh);
    });
    _tick ??= Timer.periodic(tickEvery, (_) {
      if (!isClosed) emit(state.copyWith(now: _clock()));
    });
  }

  Future<void> refresh() async {
    if (state.status != QueueStatus.loaded) return load();
    await _fetch();
  }

  void selectFilter(QueueFilter filter) => emit(state.copyWith(filter: filter));

  /// «Прийняти · 10 хв»: accepted and cooking at once.
  Future<void> accept(String id, {required int minutes}) =>
      _act(id, () => _queue.accept(id, minutes: minutes));

  /// «Готово».
  Future<void> markReady(String id) =>
      _act(id, () => _queue.setStatus(id, OrderStatus.ready));

  /// «Видати без QR»: the customer's phone died, the cook knows them.
  Future<void> handOver(String id) =>
      _act(id, () => _queue.setStatus(id, OrderStatus.pickedUp));

  Future<void> _act(String id, Future<Result<void>> Function() call) async {
    if (state.busy.contains(id)) return;
    emit(state.copyWith(busy: {...state.busy, id}, failure: null));
    final result = await call();
    if (isClosed) return;
    if (result case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
    }
    await _fetch();
    if (isClosed) return;
    emit(state.copyWith(busy: {...state.busy}..remove(id)));
  }

  Future<void> _fetch() async {
    final result = await _queue.getQueue();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final orders):
        final known = {for (final o in state.orders) o.id};
        final fresh = state.status == QueueStatus.loaded
            ? [
                for (final o in orders)
                  if (o.status == OrderStatus.paid && !known.contains(o.id))
                    o.number,
              ]
            : const <int>[];
        emit(
          state.copyWith(
            status: QueueStatus.loaded,
            orders: orders,
            now: _clock(),
            arrived: fresh.isEmpty ? state.arrived : fresh,
            arrivals: state.arrivals + (fresh.isEmpty ? 0 : 1),
          ),
        );
        if (fresh.isNotEmpty) await _alert.play();
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.status == QueueStatus.loaded
                ? QueueStatus.loaded
                : QueueStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    _tick?.cancel();
    await _live?.cancel();
    return super.close();
  }
}
