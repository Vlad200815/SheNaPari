import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/widgets/button_item.dart';

import 'support_action.dart';
import 'support_event.dart';
import 'support_state.dart';
import 'support_view_model.dart';

class SupportPage
    extends
        BasePage<SupportViewModel, SupportState, SupportEvent, SupportAction> {
  @override
  SupportViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return SupportViewModel();
  }

  @override
  void handleEvent(BuildContext context, SupportEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, SupportState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Text("Support Page"),
            const SizedBox(height: 25),
            Text("Connect with us, in a comfortable way for you"),

            const SizedBox(height: 25),
            ButtonItem.primary(
              text: "telegram",
              onTap: () => postAction(context, OnTelegramButtonPressedAction()),
            ),

            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "phone",
              onTap: () => postAction(context, OnPhoneButtonPressedAction()),
            ),

            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "email",
              onTap: () => postAction(context, OnEmailButtonPressedAction()),
            ),
          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static String path = "/support";
  static String name = "Support";

  SupportPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return SupportPage();
    });
  }

  static Future<void> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
