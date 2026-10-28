import 'package:shenapari/src/core/base/base_view_model.dart';

import 'order_success_action.dart';
import 'order_success_event.dart';
import 'order_success_state.dart';

class OrderSuccessViewModel
    extends
        BaseViewModel<
          OrderSuccessState,
          OrderSuccessEvent,
          OrderSuccessAction
        > {
  OrderSuccessViewModel() : super(OrderSuccessState());
}
