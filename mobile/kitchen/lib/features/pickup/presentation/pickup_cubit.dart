import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/result/result.dart';

import '../../queue/domain/entities/kitchen_order.dart';
import '../../queue/domain/queue_repository.dart';
import 'package:shenapari_core/result/failure.dart';

import 'pickup_state.dart';

/// The counter: a QR hands the order over at once (the server checks the
/// code); a typed number first shows the order, so the cook can match the
/// name, and hands it over on «Видати».
class PickupCubit extends Cubit<PickupState> {
  PickupCubit(this._queue, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const PickupState());

  final QueueRepository _queue;
  final DateTime Function() _clock;
  String? _lastToken;
  DateTime? _lastScanAt;

  /// The camera sees the same code many times a second: one handover.
  static const sameCodePause = Duration(seconds: 4);

  /// Order numbers restart daily and stay small.
  static const maxDigits = 3;

  static final _token = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<void> scanned(String raw) async {
    final token = raw.trim();
    if (state.status == PickupStatus.working) return;
    final now = _clock();
    final last = _lastScanAt;
    if (token == _lastToken &&
        last != null &&
        now.difference(last) < sameCodePause) {
      return;
    }
    _lastToken = token;
    _lastScanAt = now;
    if (!_token.hasMatch(token)) {
      emit(_failed(problem: PickupProblem.notOurCode));
      return;
    }
    emit(state.copyWith(status: PickupStatus.working));
    switch (await _queue.pickUp(token)) {
      case Ok(value: final order):
        _done(order);
      case Err(:final failure):
        emit(_failed(failure: failure));
    }
  }

  void digit(int digit) {
    if (state.number.length >= maxDigits) return;
    emit(
      state.copyWith(
        number: '${state.number}$digit',
        status: state.status == PickupStatus.working
            ? PickupStatus.working
            : PickupStatus.idle,
      ),
    );
  }

  void backspace() {
    if (state.number.isEmpty) return;
    emit(
      state.copyWith(
        number: state.number.substring(0, state.number.length - 1),
      ),
    );
  }

  /// «OK» on the keypad: find today's order with this number.
  Future<void> lookUp() async {
    final number = int.tryParse(state.number);
    if (number == null || state.status == PickupStatus.working) return;
    emit(state.copyWith(status: PickupStatus.working));
    switch (await _queue.getQueue()) {
      case Ok(value: final orders):
        final order = orders.where((o) => o.number == number).firstOrNull;
        if (order == null) {
          emit(_failed(problem: PickupProblem.noSuchNumber));
        } else if (order.status != OrderStatus.ready) {
          emit(_failed(problem: PickupProblem.notReadyYet, order: order));
        } else {
          emit(
            state.copyWith(
              status: PickupStatus.found,
              order: order,
              failure: null,
              problem: null,
            ),
          );
        }
      case Err(:final failure):
        emit(_failed(failure: failure));
    }
  }

  /// «Видати №36» after a typed number.
  Future<void> handOverFound() async {
    final order = state.order;
    if (state.status != PickupStatus.found || order == null) return;
    emit(state.copyWith(status: PickupStatus.working));
    switch (await _queue.setStatus(order.id, OrderStatus.pickedUp)) {
      case Ok():
        _done(order);
      case Err(:final failure):
        emit(_failed(failure: failure));
    }
  }

  void _done(KitchenOrder order) => emit(
    PickupState(
      status: PickupStatus.done,
      order: order,
      handedOver: state.handedOver + 1,
    ),
  );

  PickupState _failed({
    PickupProblem? problem,
    Failure? failure,
    KitchenOrder? order,
  }) => state.copyWith(
    status: PickupStatus.failed,
    problem: problem,
    failure: failure,
    order: order,
  );
}
