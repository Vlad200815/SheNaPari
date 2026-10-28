import 'package:shenapari/src/core/base/base_view_model.dart';

import 'cart_action.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartViewModel extends BaseViewModel<CartState, CartEvent, CartAction> {
  CartViewModel() : super(CartState());
}
