import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shenapari_core/session/session_status.dart';
import '../../menu/domain/entities/dish.dart';
import '../domain/cart_repository.dart';
import '../domain/entities/cart.dart';

/// The one cart of the app. Unlike screen cubits it is a singleton: the
/// menu, the dish screen, the cart tab and the tab-bar badge all show it.
/// Every change is saved right away.
///
/// Signing out (or deleting the account) empties it, so the next person on
/// this phone does not get someone else's dishes.
class CartCubit extends Cubit<Cart> {
  CartCubit(this._repository, {required Stream<SessionStatus> sessionChanges})
    : super(_repository.load()) {
    _session = sessionChanges.listen((status) {
      if (status == SessionStatus.unauthenticated) clear();
    });
  }

  final CartRepository _repository;
  late final StreamSubscription<SessionStatus> _session;

  void add(Dish dish, {int quantity = 1}) =>
      _update(state.add(dish, quantity: quantity));

  void setQuantity(Dish dish, int quantity) =>
      _update(state.setQuantity(dish, quantity));

  /// After the menu is loaded (also after a language switch).
  void updateDishes(Iterable<Dish> dishes) =>
      _update(state.withFreshDishes(dishes));

  void remove(int dishId) => _update(state.remove(dishId));

  void removeSoldOut() => _update(state.withoutSoldOut());

  void clear() => _update(const Cart());

  void _update(Cart cart) {
    if (cart == state) return;
    emit(cart);
    _repository.save(cart);
  }

  @override
  Future<void> close() async {
    await _session.cancel();
    return super.close();
  }
}
