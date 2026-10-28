import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ota_update/ota_update.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/others/controller/connectivity_controller.dart';
import 'package:shenapari/src/core/preference/app_preference.dart' as pref;
import 'package:shenapari/src/core/resource/theme.dart';
import 'package:shenapari/src/core/widgets/update/app_update_info_dialog.dart';
import 'package:shenapari/src/core/widgets/update/core/base_update_client.dart';
import 'package:shenapari/src/core/widgets/update/core/base_update_widget.dart';
import 'package:shenapari/src/core/widgets/update/core/update_info.dart';
import 'package:shenapari/src/core/widgets/update/core/update_method.dart';

import 'app_action.dart';
import 'app_event.dart';
import 'app_state.dart';
import 'app_view_model.dart';

class AppPage
    extends BaseApplication<AppViewModel, AppState, AppEvent, AppAction> {
  AppPage({super.key});

  // final AppStateController appStateController = Get.put(AppStateController());
  final ConnectivityController connectivityController = Get.put(
    ConnectivityController.getInstance(),
  );

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  AppViewModel viewModel() => AppViewModel();

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // String? initialRoute;

  @override
  void handleEvent(BuildContext context, AppEvent event) {
    // switch (event) {
    // case OpenHomePageEvent _:
    //   Navigation.router().go(HomePage.path);
    // // case OpenDetailPageEvent event:
    // //   Navigation.router().push("/detail/${event.movieId}");
    // case OpenOnBoardingPageEvent _:
    //   Navigation.router().go(OnboardingPage.path);
    // }
  }

  @override
  Widget createView(BuildContext context, AppState state) {
    final locale = context.locale.languageCode;
    pref.AppPreference.setLanguage(locale);

    return MaterialApp.router(
      title: Config.APP_TITLE,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Automatically follows phone settings
      builder: (context, child) {
        return BaseUpdateWidget(
          navigatorKey: _rootNavigatorKey,
          updateClient: BaseUpdateClient(
            fetchAppVersionInfo: () async {
              return Future.value(UpdateInfo());
            },
            iosAppStoreId: Config.IOS_APPSTORE_ID,
            updateMethods: [UpdateMethod.native, UpdateMethod.store],
            otaPageBuilder: (Stream<OtaEvent> stream) => SizedBox(),
          ),

          showUpdateAlert: (context, allowCancel) async {
            return NewVersionAlertDialog(
              canDismiss: allowCancel,
              onConfirm: () {},
            ).show(context);
          },
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: Navigation.router(),
    );
  }
}
