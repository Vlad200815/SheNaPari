import 'package:shenapari/src/core/base/base_view_model.dart';

import 'product_details_action.dart';
import 'product_details_event.dart';
import 'product_details_state.dart';

class ProductDetailsViewModel
    extends
        BaseViewModel<
          ProductDetailsState,
          ProductDetailsEvent,
          ProductDetailsAction
        > {
  ProductDetailsViewModel() : super(ProductDetailsState());
}
