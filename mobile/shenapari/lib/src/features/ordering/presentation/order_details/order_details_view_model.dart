import 'package:shenapari/src/core/base/base_view_model.dart';

import 'order_details_action.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsViewModel
    extends
        BaseViewModel<
          OrderDetailsState,
          OrderDetailsEvent,
          OrderDetailsAction
        > {
  OrderDetailsViewModel() : super(OrderDetailsState());
}
