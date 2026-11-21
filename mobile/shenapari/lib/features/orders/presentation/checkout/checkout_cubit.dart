import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/orders/order_events.dart';

import 'package:shenapari_core/result/result.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../menu/domain/entities/break_slot.dart';
import '../../../menu/domain/menu_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/orders_repository.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  /// [items] is the cart at the moment checkout opened. The cubit does not
  /// touch the cart: the page empties it once the order is placed.
  /// The kitchen's pause switch is followed live ([OrderEvents]), so
  /// «Оплатити» turns off and on without reopening the page.
  CheckoutCubit(
    this._menu,
    this._orders,
    this._events, {
    required this.items,
    required PaymentProvider defaultProvider,
  }) : super(CheckoutState(provider: defaultProvider));

  final MenuRepository _menu;
  final OrdersRepository _orders;
  final OrderEvents _events;
  final List<CartItem> items;
  StreamSubscription<bool>? _pause;

  Future<void> load() async {
    _pause ??= _events.acceptingOrders.listen(
      (accepting) => emit(state.copyWith(isAcceptingOrders: accepting)),
    );
    emit(state.copyWith(status: CheckoutStatus.loading, failure: null));
    final (breaks, canteen) = await (
      _menu.getTodayBreaks(),
      _menu.getCanteen(),
    ).wait;
    switch ((breaks, canteen)) {
      case (Ok(value: final breaks), Ok(value: final canteen)):
        emit(
          state.copyWith(
            status: CheckoutStatus.ready,
            breaks: breaks,
            // The nearest break by default: that is what the app is for.
            breakSlotId: breaks.isEmpty ? null : breaks.first.id,
            isAcceptingOrders: canteen.isAcceptingOrders,
          ),
        );
      case (Err(:final failure), _) || (_, Err(:final failure)):
        emit(
          state.copyWith(status: CheckoutStatus.loadFailure, failure: failure),
        );
    }
  }

  /// [breakSlotId] null = «as soon as possible».
  void selectBreak(int? breakSlotId) =>
      emit(state.copyWith(breakSlotId: breakSlotId, failure: null));

  void selectProvider(PaymentProvider provider) =>
      emit(state.copyWith(provider: provider, failure: null));

  Future<void> pay() async {
    if (!state.canPay || items.isEmpty) return;
    emit(state.copyWith(status: CheckoutStatus.placing, failure: null));

    final result = await _orders.placeOrder(
      items: items,
      breakSlotId: state.breakSlotId,
      provider: state.provider,
    );
    switch (result) {
      case Ok(value: final order):
        emit(state.copyWith(status: CheckoutStatus.placed, order: order));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: CheckoutStatus.ready,
            failure: failure,
            isAcceptingOrders:
                failure.code != 'order.canteen_paused' &&
                state.isAcceptingOrders,
          ),
        );
        // The chosen break started while the user was deciding.
        if (failure.code == 'order.break_passed') await _refreshBreaks();
        // A dish ran out after the menu was loaded.
        if (failure.code == 'order.dish_unavailable') await _refreshDishes();
    }
  }

  Future<void> _refreshDishes() async {
    if (await _menu.getDishes() case Ok(value: final dishes)) {
      emit(state.copyWith(freshDishes: dishes));
    }
  }

  Future<void> _refreshBreaks() async {
    if (await _menu.getTodayBreaks() case Ok(value: final breaks)) {
      final stillThere = breaks.any((b) => b.id == state.breakSlotId);
      emit(
        state.copyWith(
          breaks: breaks,
          breakSlotId: stillThere ? state.breakSlotId : _firstOrNull(breaks),
        ),
      );
    }
  }

  static int? _firstOrNull(List<BreakSlot> breaks) =>
      breaks.isEmpty ? null : breaks.first.id;

  @override
  Future<void> close() async {
    await _pause?.cancel();
    return super.close();
  }
}
