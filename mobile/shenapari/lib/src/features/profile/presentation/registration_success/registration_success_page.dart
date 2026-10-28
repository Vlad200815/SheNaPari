import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/widgets/button_item.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_page.dart';

import 'registration_success_action.dart';
import 'registration_success_event.dart';
import 'registration_success_state.dart';
import 'registration_success_view_model.dart';

class RegistrationSuccessPage
    extends
        BasePage<
          RegistrationSuccessViewModel,
          RegistrationSuccessState,
          RegistrationSuccessEvent,
          RegistrationSuccessAction
        > {
  @override
  RegistrationSuccessViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    // TODO: implement viewModelProvider
    return RegistrationSuccessViewModel();
  }

  @override
  void handleEvent(BuildContext context, event) {
    switch (event) {
      case OpenHomePageEvent _:
        HomePage.open(context);
    }
  }

  @override
  Widget createView(BuildContext context, RegistrationSuccessState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Center(child: Text("Registration Success Page")),
            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "Got it",
              onTap: () => postAction(context, OnGotItButtonPressedAction()),
            ),
          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static const String path = "/registration_success";
  static const String name = "RegistrationSuccess";

  RegistrationSuccessPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return RegistrationSuccessPage();
    });
  }

  static Future<Object?> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
