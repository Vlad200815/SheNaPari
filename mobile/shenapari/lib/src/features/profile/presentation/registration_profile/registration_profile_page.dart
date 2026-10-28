import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:shenapari/src/app/navigation.dart";
import "package:shenapari/src/core/base/base_page.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/widgets/app_bar_item.dart";
import "package:shenapari/src/core/widgets/button_item.dart";

import "../registration_success/registration_success_page.dart";
import "registration_profile_action.dart";
import "registration_profile_event.dart";
import "registration_profile_state.dart";
import "registration_profile_view_model.dart";

class RegistrationProfilePage
    extends
        BasePage<
          RegistrationProfileViewModel,
          RegistrationProfileState,
          RegistrationProfileEvent,
          RegistrationProfileAction
        > {
  @override
  RegistrationProfileViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return RegistrationProfileViewModel();
  }

  @override
  void handleEvent(BuildContext context, RegistrationProfileEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, RegistrationProfileState state) {
    return Scaffold(
      appBar: AppBarItem(titleWidget: Text("Registration Profile Page")),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonItem.primary(
                text: "Next",
                onTap: () => RegistrationSuccessPage.open(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static const String path = "/registration_profile";
  static const String name = "RegistrationProfile";

  RegistrationProfilePage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return RegistrationProfilePage();
    });
  }

  static Future<Object?> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
