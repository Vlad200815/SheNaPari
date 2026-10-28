import 'package:flutter/material.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/features/ordering/presentation/order_details/order_details_view_model.dart';

import 'order_details_action.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsPage
    extends
        BasePage<
          OrderDetailsViewModel,
          OrderDetailsState,
          OrderDetailsEvent,
          OrderDetailsAction
        > {
  OrderDetailsPage({super.key});

  @override
  OrderDetailsViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return OrderDetailsViewModel();
  }

  @override
  void handleEvent(BuildContext context, OrderDetailsEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, OrderDetailsState state) {
    return Scaffold(body: Center(child: Text("Order Details")));
  }
}
