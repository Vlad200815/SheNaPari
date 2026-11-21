import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/orders/order_events.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/canteen_repository.dart';
import 'canteen_state.dart';

/// «Приймаємо / Пауза» in the kitchen's header. Follows the switch live,
/// so a pause on the tablet shows on the phone at the counter too.
class CanteenCubit extends Cubit<CanteenState> {
  CanteenCubit(this._repository, this._events) : super(const CanteenState());

  final CanteenRepository _repository;
  final OrderEvents _events;
  StreamSubscription<bool>? _live;
  StreamSubscription<String?>? _reconnects;

  Future<void> load() async {
    _live ??= _events.acceptingOrders.listen(
      (accepting) => emit(
        state.copyWith(status: CanteenStatus.loaded, accepting: accepting),
      ),
    );
    // `null` = updates may have been missed while offline.
    _reconnects ??= _events.changes
        .where((id) => id == null)
        .listen((_) => _fetch());
    await _fetch();
  }

  Future<void> pause() => _set(false);

  Future<void> resume() => _set(true);

  Future<void> _fetch() async {
    final result = await _repository.isAcceptingOrders();
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final accepting) => state.copyWith(
        status: CanteenStatus.loaded,
        accepting: accepting,
      ),
      // Keep what we knew; a first load failing hides the switch.
      Err() when state.status == CanteenStatus.loaded => state,
      Err(:final failure) => state.copyWith(
        status: CanteenStatus.failure,
        failure: failure,
      ),
    });
  }

  Future<void> _set(bool accepting) async {
    if (state.busy || state.accepting == accepting) return;
    emit(state.copyWith(busy: true, failure: null));
    final result = await _repository.setAcceptingOrders(accepting);
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final accepting) => state.copyWith(
        busy: false,
        accepting: accepting,
      ),
      Err(:final failure) => state.copyWith(busy: false, failure: failure),
    });
  }

  @override
  Future<void> close() async {
    await _live?.cancel();
    await _reconnects?.cancel();
    return super.close();
  }
}
