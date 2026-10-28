import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';

import 'product_details_action.dart';
import 'product_details_event.dart';
import 'product_details_state.dart';
import 'product_details_view_model.dart';

class ProductDetailsPage
    extends
        BasePage<
          ProductDetailsViewModel,
          ProductDetailsState,
          ProductDetailsEvent,
          ProductDetailsAction
        > {
  final String productId;
  final String section;

  ProductDetailsPage({
    super.key,
    required this.productId,
    required this.section,
  });

  @override
  ProductDetailsViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return ProductDetailsViewModel();
  }

  @override
  void handleEvent(BuildContext context, ProductDetailsEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, ProductDetailsState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const Text("Detail Screen"),
              const SizedBox(height: 15),
              Text(productId),
              const SizedBox(height: 5),
              Text(section),
            ],
          ),
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static const String path = "/product_details/:$paramId";
  static const String name = "ProductDetails";
  static const String paramId = "param_id";

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      final String productId = state.pathParameters[paramId].orEmpty();
      final String section = state.extra as String;

      return ProductDetailsPage(productId: productId, section: section);
    });
  }

  static Future<Object?> open(
    BuildContext context, {
    required String id,
    required String section,
  }) {
    return context.pushNamed(
      name,
      pathParameters: {paramId: id},
      extra: section,
    );
  }
}
