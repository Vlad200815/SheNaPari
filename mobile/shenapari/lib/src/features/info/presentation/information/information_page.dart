import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:shenapari/src/app/config.dart";
import "package:shenapari/src/app/navigation.dart";
import "package:shenapari/src/core/base/base_page.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/features/info/presentation/information/information_view_model.dart";
import "package:shenapari/src/features/info/presentation/legal/legal_page.dart";

import "../../../../core/widgets/widgets.dart";
import "information_action.dart";
import "information_event.dart";
import "information_state.dart";

class InformationPage
    extends
        BasePage<
          InformationViewModel,
          InformationState,
          InformationEvent,
          InformationAction
        > {
  @override
  InformationViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    // TODO: implement viewModelProvider
    return InformationViewModel();
  }

  @override
  void handleEvent(BuildContext context, InformationEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, InformationState state) {
    // TODO: implement createView
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Text("Information"),
            const SizedBox(height: 25),
            ButtonItem.primary(
              text: "Terms of Use",
              onTap: () => LegalPage.open(
                context,
                documentType: DocumentType.termsOfUse,
              ),
            ),
            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "Privacy Policy",
              onTap: () => LegalPage.open(
                context,
                documentType: DocumentType.privacyPolicy,
              ),
            ),
            const SizedBox(height: 10),
            ButtonItem.primary(
              text: "Removal conditions",
              onTap: () => LegalPage.open(
                context,
                documentType: DocumentType.removalConditions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static String path = "/information";
  static String name = "Information";

  InformationPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return InformationPage();
    });
  }

  static Future<void> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
