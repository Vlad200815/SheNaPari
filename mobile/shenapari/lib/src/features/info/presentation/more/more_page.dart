import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/features/info/presentation/information/information_page.dart';
import 'package:shenapari/src/features/info/presentation/more/more_event.dart';
import 'package:shenapari/src/features/info/presentation/more/more_state.dart';
import 'package:shenapari/src/features/info/presentation/more/more_view_model.dart';
import 'package:shenapari/src/features/info/presentation/support/support_page.dart';
import 'package:shenapari/src/features/profile/presentation/profile/profile_page.dart';

import '../../../../core/widgets/widgets.dart';
import 'more_action.dart';

class MorePage
    extends BasePage<MoreViewModel, MoreState, MoreEvent, MoreAction> {
  @override
  MoreViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return MoreViewModel();
  }

  @override
  void handleEvent(BuildContext context, MoreEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, MoreState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("More Page"),
            const SizedBox(height: 25),
            ButtonItem.primary(
              text: "Profile",
              onTap: () => ProfilePage.open(context),
            ),
            const SizedBox(height: 15),
            // ButtonItem.primary(
            //   text: "Purchase History",
            //   onTap: () => PurchaseHistoryPage.open(context),
            // ),
            // const SizedBox(height: 15),
            ButtonItem.primary(
              text: "Support",
              onTap: () => SupportPage.open(context),
            ),
            const SizedBox(height: 15),
            ButtonItem.primary(
              text: "Information",
              onTap: () => InformationPage.open(context),
            ),
          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static String path = "/more";
  static String name = "More";

  MorePage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return MorePage();
    });
  }

  static Future<void> open(BuildContext context) async {
    return context.go(Uri(path: path).toString());
  }
}
