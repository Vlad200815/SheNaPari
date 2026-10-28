import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/features/auth/presentation/opt_verify/otp_verify_page.dart';
import 'package:shenapari/src/features/auth/presentation/phone_auth/phone_auth_page.dart';
import 'package:shenapari/src/features/cart/presentation/cart/cart_page.dart';
import 'package:shenapari/src/features/info/presentation/information/information_page.dart';
import 'package:shenapari/src/features/info/presentation/legal/legal_page.dart';
import 'package:shenapari/src/features/info/presentation/more/more_page.dart';
import 'package:shenapari/src/features/info/presentation/notifications/notifications_page.dart';
import 'package:shenapari/src/features/info/presentation/onboarding/onboarding_page.dart';
import 'package:shenapari/src/features/info/presentation/support/support_page.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_page.dart';
import 'package:shenapari/src/features/menu/presentation/product_details/product_details_page.dart';
import 'package:shenapari/src/features/menu/presentation/search/search_page.dart';
import 'package:shenapari/src/features/profile/presentation/profile/profile_page.dart';
import 'package:shenapari/src/features/profile/presentation/registration_profile/registration_profile_page.dart';
import 'package:shenapari/src/features/profile/presentation/registration_success/registration_success_page.dart';
import 'package:shenapari/src/features/root/root_page.dart';

class Navigation {
  // Private navigators
  static final _branchHomeKey = GlobalKey<NavigatorState>();
  static final _branchSearchKey = GlobalKey<NavigatorState>();
  static final _branchOrdersKey = GlobalKey<NavigatorState>();
  static final _branchProfileKey = GlobalKey<NavigatorState>();

  // Paths that do not need authentication
  static const Set _publicPaths = {
    OnboardingPage.path,
    PhoneAuthPage.path,
    OtpVerifyPage.path,
    LegalPage.path,
    RegistrationProfilePage.path,
    RegistrationSuccessPage.path,
  };

  ///
  /// Global navigation config
  ///

  static GoRouter? _instance;

  static GoRouter router() {
    if (_instance != null) return _instance!;
    _instance = GoRouter(
      debugLogDiagnostics: true,
      // initialLocation: PhoneAuthPage.path,
      initialLocation: HomePage.path,
      observers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],

      // notified when auth and (intro = onboarding) changes
      refreshListenable: Listenable.merge([authNotifier, introNotifier]),

      // redirect: _redirect,
      errorBuilder: (context, state) {
        debugPrint("GoRouter caught an invalid path: ${state.uri}");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: ColorName.primary400),
          ),
        );
      },
      routes: [
        /// Navigation stack
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return RootPage(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            ///Home
            StatefulShellBranch(
              navigatorKey: _branchHomeKey,
              routes: <RouteBase>[HomePage.route()],
            ),

            ///Search
            StatefulShellBranch(
              navigatorKey: _branchSearchKey,
              routes: <RouteBase>[SearchPage.route()],
            ),

            ///Discover
            StatefulShellBranch(
              navigatorKey: _branchOrdersKey,
              routes: <RouteBase>[CartPage.route()],
            ),

            ///Profile
            StatefulShellBranch(
              navigatorKey: _branchProfileKey,
              routes: <RouteBase>[MorePage.route()],
            ),
          ],
        ),

        // Onboarding
        OnboardingPage.route(),

        //
        // Auth
        //
        PhoneAuthPage.route(),
        OtpVerifyPage.route(),

        // Legal
        LegalPage.route(),

        // Registration Profile
        RegistrationProfilePage.route(),

        // Registration Success
        RegistrationSuccessPage.route(),

        // Product Details
        ProductDetailsPage.route(),

        // Notifications
        NotificationsPage.route(),

        //
        // More
        //
        ProfilePage.route(),
        SupportPage.route(),
        InformationPage.route(),

        //TODO: add these later
        // PurchaseHistoryPage.route(),
        // PurchaseDetailsPage.route(),
      ],
    );
    return _instance!;
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final bool isAuth = authNotifier.value;
    final bool isIntroShown = introNotifier.value;
    final path = state.uri.path;
    final isPublic = _publicPaths.contains(path);

    // Intro never shown -> onboarding first
    if (!isIntroShown && path != OnboardingPage.path) {
      return OnboardingPage.path;
    }

    // Not authenticated and trying to access a protected screen → phone auth
    if (!isAuth && !isPublic) {
      return PhoneAuthPage.path;
    }

    // Already authenticated and on auth or onboarding screen → go to home
    if (isAuth && isPublic && path != LegalPage.path) {
      return HomePage.path;
    }

    return null;
  }

  ///
  /// Create default route with config
  ///

  static GoRoute getRoute(
    String name,
    String path,

    final Widget Function(GoRouterState state) callback, {
    GlobalKey<NavigatorState>? navKey,
    final Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    )?
    transitionBuilder,
  }) {
    return GoRoute(
      parentNavigatorKey: navKey,
      name: name,
      path: path,
      pageBuilder: (context, state) {
        if (transitionBuilder != null) {
          return CustomTransitionPage(
            child: callback(state),
            transitionsBuilder: transitionBuilder,
          );
        }

        if (Platform.isIOS) {
          return CupertinoPage(child: callback(state));
        } else {
          return MaterialPage(child: callback(state));
        }
      },
    );
  }
}
