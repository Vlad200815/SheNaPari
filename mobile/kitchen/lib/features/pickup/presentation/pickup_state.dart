import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../queue/domain/entities/kitchen_order.dart';

part 'pickup_state.freezed.dart';

enum PickupStatus {
  /// Waiting for a QR or a number.
  idle,
  working,

  /// [PickupState.order] was handed over.
  done,

  /// A number found a ready order: «Видати №36» waits for a tap.
  found,

  /// See [PickupState.failure] (from the server) or [PickupState.problem].
  failed,
}

/// What the app can tell without the server.
enum PickupProblem {
  /// A QR, but not ours (a link, a ticket from somewhere else).
  notOurCode,

  /// No order with this number on today's board.
  noSuchNumber,

  /// The order exists but is not ready yet.
  notReadyYet,
}

@freezed
abstract class PickupState with _$PickupState {
  const factory PickupState({
    @Default(PickupStatus.idle) PickupStatus status,

    /// The digits typed on the keypad.
    @Default('') String number,
    KitchenOrder? order,
    Failure? failure,
    PickupProblem? problem,

    /// Counts handovers, so two in a row each get their tick.
    @Default(0) int handedOver,
  }) = _PickupState;
}
