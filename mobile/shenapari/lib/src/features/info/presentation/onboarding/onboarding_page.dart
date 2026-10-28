import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:shenapari/gen/assets.gen.dart";
import "package:shenapari/generated/locale_keys.g.dart";
import "package:shenapari/src/app/navigation.dart";
import "package:shenapari/src/core/base/base_page.dart";
import "package:shenapari/src/core/others/extension/extensions.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/features/auth/presentation/phone_auth/phone_auth_page.dart";
import "package:shenapari/src/features/info/presentation/onboarding/onboarding_view_model.dart";
import "package:shenapari/src/features/info/presentation/onboarding/widgets/widgets.dart";

import "../../../../core/widgets/widgets.dart";
import "onboarding_action.dart";
import "onboarding_event.dart";
import "onboarding_state.dart";

class OnboardingPage
    extends
        BasePage<
          OnboardingViewModel,
          OnboardingState,
          OnboardingEvent,
          OnboardingAction
        > {
  @override
  OnboardingViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return OnboardingViewModel();
  }

  @override
  void handleEvent(BuildContext context, OnboardingEvent event) {
    switch (event) {
      case OpenPhoneAuthPageEvent _:
        PhoneAuthPage.open(context);
    }
  }

  final int initialPage = 0;

  final List<String> images = [
    Assets.images.onboarding.welcome.path,
    Assets.images.onboarding.orderInSeconds.path,
    Assets.images.onboarding.realtimeNotifications.path,
  ];

  List<String> get titles => [
    LocaleKeys.onboarding_page_welcome_title.tr(),
    LocaleKeys.onboarding_page_order_on_fly_title.tr(),
    LocaleKeys.onboarding_page_peace_of_mind_title.tr(),
  ];

  List<String> get subTitles => [
    LocaleKeys.onboarding_page_app_name_title.tr(),
    LocaleKeys.onboarding_page_skip_rush_text.tr(),
    LocaleKeys.onboarding_page_real_time_notifications_text.tr(),
  ];

  PageController? _pageController;


  @override
  void onInit(BuildContext context) {
    _pageController = PageController(initialPage: initialPage);
    super.onInit(context);
  }

  @override
  void onDestroy() {
    _pageController?.dispose();
    super.onDestroy();
  }

  @override
  Widget createView(BuildContext context, OnboardingState state) {


    final isLast = state.selectedPage == images.length - 1;


    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: SvgPicture.asset(Assets.images.icLogo.path)),
            ),

            Expanded(
              child: PageView.builder(
                onPageChanged: (selectedPage) => postAction(
                  context,
                  OnPageChangedAction(selectedPage: selectedPage),
                ),
                controller: _pageController,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(
                    selectedIndex: index,
                    image: images[index],
                    subTitle: subTitles[index],
                    title: titles[index],
                    length: images.length,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: PageProgressBarView(
                selectedPage: state.selectedPage.orZero(),
                length: images.length,
              ),
            ),

            const SizedBox(height: 20),

            ButtonItem.primary(
              text: isLast ?
                LocaleKeys.onboarding_page_start_button_title.tr() :
                LocaleKeys.onboarding_page_next_button_title.tr(),

              onTap: () => postAction(
                context, isLast ?
              OnStartButtonPressedAction() :
              OnNextButtonPressedAction(pageController: _pageController),
              ),
              horizontalPadding: Dimen.DEFAULT_HORIZONTAL_PADDING,
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: !isLast,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: ButtonItem.outlined(
                text: LocaleKeys.onboarding_page_skip_button_title.tr(),
                onTap: () => postAction(context, OnSkipButtonPressedAction()),
                horizontalPadding: Dimen.DEFAULT_HORIZONTAL_PADDING,
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static const String path = "/onboarding";
  static const String name = "Onboarding";

  OnboardingPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return OnboardingPage();
    });
  }

  static void open(BuildContext context) {
    return context.go(Uri(path: path).toString());
  }
}
