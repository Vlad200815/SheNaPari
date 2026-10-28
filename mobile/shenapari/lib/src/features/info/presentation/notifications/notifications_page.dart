import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/features/info/presentation/notifications/notifications_view_model.dart';

import 'notifications_action.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsPage
    extends
        BasePage<
          NotificationsViewModel,
          NotificationsState,
          NotificationsEvent,
          NotificationsAction
        > {
  @override
  NotificationsViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return NotificationsViewModel();
  }

  @override
  void handleEvent(BuildContext context, NotificationsEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, NotificationsState state) {
    return Scaffold(body: Center(child: Text("Notifications Page")));
  }

  //
  // Navigation
  //
  static String path = "/notifications";
  static String name = "Notifications";

  NotificationsPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return NotificationsPage();
    });
  }

  static Future<void> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
