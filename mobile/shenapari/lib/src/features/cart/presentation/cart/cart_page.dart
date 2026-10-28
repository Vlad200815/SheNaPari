import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/features/cart/presentation/cart/cart_view_model.dart';

import 'cart_action.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartPage
    extends BasePage<CartViewModel, CartState, CartEvent, CartAction> {
  @override
  CartViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return CartViewModel();
  }

  @override
  void handleEvent(BuildContext context, CartEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, CartState state) {
    return Scaffold(body: Center(child: Text("Cart Page")));
  }

  //
  // Navigation
  //
  static String path = "/cart";
  static String name = "Cart";

  CartPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return CartPage();
    });
  }

  static void open(BuildContext context) {
    return context.go(Uri(path: path).toString());
  }
}
