import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/features/info/presentation/widgets/rules_view.dart';

import '../../../../core/widgets/widgets.dart';
import 'legal_action.dart';
import 'legal_event.dart';
import 'legal_state.dart';
import 'legal_view_model.dart';

class LegalPage
    extends BasePage<LegalViewModel, LegalState, LegalEvent, LegalAction> {
  final DocumentType? documentType;

  final ScrollController _scrollController = ScrollController();

  LegalPage({super.key, required this.documentType});

  @override
  void onDestroy() {
    _scrollController.dispose();
    super.onDestroy();
  }

  @override
  LegalViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return LegalViewModel(
      fetchPrivacyPolicyUseCase: di.get(),
      fetchTermsOfUseUseCase: di.get(),
      documentType: documentType,
    );
  }

  @override
  void handleEvent(BuildContext context, LegalEvent event) {
    switch (event) {}
  }

  @override
  Widget createView(BuildContext context, LegalState state) {
    return Scaffold(
      appBar: AppBarItem(hasLeading: true),
      body: Column(
        children: [
          const SizedBox(height: 14),

          Expanded(
            child: switch (documentType) {
              /// Error Case
              //TODO: make it valid
              null => Center(child: Text("Something went wrong")),

              /// Terms Of Use
              DocumentType.termsOfUse => RulesView(
                onTapLink: (text, href, title) =>
                    postAction(context, OnLinkPressedAction(href: href)),
                scrollController: _scrollController,
                title: LocaleKeys.phone_auth_terms_of_use_title.tr(),
                subTitle: LocaleKeys.phone_auth_terms_of_use_subtitle.tr(),
                documentContent: state.documentContent.orEmpty(),
              ),

              /// Privacy Policy
              DocumentType.privacyPolicy => RulesView(
                onTapLink: (text, href, title) =>
                    postAction(context, OnLinkPressedAction(href: href)),
                scrollController: _scrollController,
                title: LocaleKeys.phone_auth_privacy_policy_title.tr(),
                subTitle: LocaleKeys.phone_auth_privacy_policy_subtitle.tr(),
                documentContent: state.documentContent.orEmpty(),
              ),
              // TODO: Handle this case.
              DocumentType.removalConditions => Center(
                child: Text("Removal conditions"),
              ),
            },
          ),
        ],
      ),
    );
  }

  // Navigation
  static const String path = "/legal";
  static const String name = "Legal";

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      final documentType = state.extra as DocumentType?;

      return LegalPage(documentType: documentType);
    });
  }

  static Future<Object?> open(
    BuildContext context, {
    required DocumentType documentType,
  }) {
    return context.push(Uri(path: path).toString(), extra: documentType);
  }
}
