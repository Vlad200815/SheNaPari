import 'package:flutter/material.dart';
import 'package:shenapari/src/core/base/base_page.dart';

import 'order_success_action.dart';
import 'order_success_event.dart';
import 'order_success_state.dart';
import 'order_success_view_model.dart';

class OrderSuccessPage
    extends
        BasePage<
          OrderSuccessViewModel,
          OrderSuccessState,
          OrderSuccessEvent,
          OrderSuccessAction
        > {
  OrderSuccessPage({super.key});

  @override
  OrderSuccessViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return OrderSuccessViewModel();
  }

  @override
  void handleEvent(BuildContext context, OrderSuccessEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, OrderSuccessState state) {
    return Scaffold(body: Center(child: Text("Order Success")));
  }
}
