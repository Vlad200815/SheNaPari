import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import '../../../menu/domain/entities/break_slot.dart';
import '../../domain/entities/order.dart';

part 'checkout_state.freezed.dart';

/// `loadFailure`: breaks/canteen could not be loaded, nothing to choose
/// from. A failed payment goes back to `ready` with [CheckoutState.failure]
/// set, so the choices stay and a snack bar explains.
enum CheckoutStatus { loading, loadFailure, ready, placing, placed }

@freezed
abstract class CheckoutState with _$CheckoutState {
  const CheckoutState._();

  const factory CheckoutState({
    @Default(CheckoutStatus.loading) CheckoutStatus status,

    /// Today's breaks that have not started yet.
    @Default(<BreakSlot>[]) List<BreakSlot> breaks,

    /// The chosen break; null = «as soon as possible».
    int? breakSlotId,
    required PaymentProvider provider,
    @Default(true) bool isAcceptingOrders,

    /// Set once placed.
    Order? order,
    Failure? failure,
  }) = _CheckoutState;

  bool get canPay => status == CheckoutStatus.ready && isAcceptingOrders;
}
