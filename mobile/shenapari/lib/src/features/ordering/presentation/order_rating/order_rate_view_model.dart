import 'package:shenapari/src/core/base/base_view_model.dart';

import 'order_rating_action.dart';
import 'order_rating_event.dart';
import 'order_rating_state.dart';

class OrderRatingViewModel
    extends
        BaseViewModel<OrderRatingState, OrderRatingEvent, OrderRatingAction> {
  OrderRatingViewModel() : super(OrderRatingState());
}
