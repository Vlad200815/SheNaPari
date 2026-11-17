import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../domain/entities/dish.dart';
import '../../domain/menu_repository.dart';
import 'dish_state.dart';

class DishCubit extends Cubit<DishState> {
  /// [initial] is the dish the menu already has: the screen shows it at
  /// once instead of a loader. Without it (e.g. opened after a restart) the
  /// dish is loaded by [dishId].
  DishCubit(this._menu, {required this.dishId, Dish? initial})
    : super(
        initial == null
            ? const DishState()
            : DishState(status: DishStatus.loaded, dish: initial),
      );

  final MenuRepository _menu;
  final int dishId;

  Future<void> load() async {
    final hasDish = state.dish != null;
    if (!hasDish) {
      emit(state.copyWith(status: DishStatus.loading, failure: null));
    }
    final (dishResult, breakResult) = await (
      hasDish ? Future.value(Ok(state.dish!)) : _menu.getDish(dishId),
      _menu.getNextBreak(),
    ).wait;

    // The pickup hint is a nicety: without it the dish still shows.
    final nextBreak = switch (breakResult) {
      Ok(:final value) => value,
      Err() => null,
    };
    switch (dishResult) {
      case Ok(value: final dish):
        emit(
          state.copyWith(
            status: DishStatus.loaded,
            dish: dish,
            nextBreak: nextBreak,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(status: DishStatus.failure, failure: failure));
    }
  }

  void setQuantity(int quantity) =>
      emit(state.copyWith(quantity: quantity.clamp(1, Cart.maxQuantity)));
}
