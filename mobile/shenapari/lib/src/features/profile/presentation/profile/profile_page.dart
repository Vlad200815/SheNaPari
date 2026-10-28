import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/widgets/button_item.dart';

import 'profile_action.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'profile_view_model.dart';

class ProfilePage
    extends
        BasePage<ProfileViewModel, ProfileState, ProfileEvent, ProfileAction> {
  @override
  ProfileViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return ProfileViewModel();
  }

  @override
  void handleEvent(BuildContext context, ProfileEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, ProfileState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Profile Page"),
            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "Log Out",
              onTap: () => postAction(context, OnLogOutButtonPressedAction()),
            ),
          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static String path = "/profile";
  static String name = "Profile";

  ProfilePage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return ProfilePage();
    });
  }

  static Future<void> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
