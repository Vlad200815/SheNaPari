import 'package:flutter/material.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/features/ordering/presentation/order_rating/order_rate_view_model.dart';

import 'order_rating_action.dart';
import 'order_rating_event.dart';
import 'order_rating_state.dart';

class OrderRatingPage
    extends
        BasePage<
          OrderRatingViewModel,
          OrderRatingState,
          OrderRatingEvent,
          OrderRatingAction
        > {
  OrderRatingPage({super.key});

  @override
  OrderRatingViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return OrderRatingViewModel();
  }

  @override
  void handleEvent(BuildContext context, OrderRatingEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, OrderRatingState state) {
    return Scaffold(body: Center(child: Text("Order Rating")));
  }
}
