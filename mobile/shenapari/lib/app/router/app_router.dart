import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_repository.dart';
import '../../core/storage/app_prefs.dart';
import '../../features/auth/presentation/code/code_page.dart';
import '../../features/auth/presentation/phone/phone_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/legal/domain/entities/legal_document.dart';
import '../../features/legal/presentation/legal_page.dart';
import '../../features/menu/domain/entities/dish.dart';
import '../../features/menu/presentation/dish/dish_page.dart';
import '../../features/menu/presentation/home/home_page.dart';
import '../../features/orders/presentation/checkout/checkout_page.dart';
import '../../features/orders/presentation/my_qr/my_qr_page.dart';
import '../../features/orders/presentation/order/order_page.dart';
import '../../features/orders/presentation/orders/orders_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/faq/faq_page.dart';
import '../../features/profile/presentation/more/more_page.dart';
import '../../features/profile/presentation/my_profile/my_profile_page.dart';
import '../../features/profile/presentation/settings/settings_page.dart';
import '../../features/profile/presentation/support/support_page.dart';
import '../../features/profile/presentation/registration_profile/registration_profile_page.dart';
import '../splash_page.dart';
import 'app_redirect.dart';
import 'main_shell.dart';
import 'routes.dart';
import 'stream_listenable.dart';

/// The router re-runs [appRedirect] whenever the session or the onboarding
/// flag changes, so screens never navigate manually after sign-in/sign-out.
GoRouter createRouter({
  required SessionRepository session,
  required AppPrefs prefs,
  required Future<void> Function() signOut,
}) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: Listenable.merge([
      StreamListenable(session.statusChanges),
      prefs,
    ]),
    redirect: (context, state) => appRedirect(
      status: session.status,
      onboardingSeen: prefs.onboardingSeen,
      location: state.matchedLocation,
    ),
    routes: [
      // Screens the redirect switches between must not slide in like a
      // pushed page: the user did not navigate, the session state changed.
      GoRoute(
        path: Routes.splash,
        pageBuilder: (_, state) => _instant(state, const SplashPage()),
      ),
      GoRoute(
        path: Routes.onboarding,
        // Appears right under the native splash and looks the same, so
        // any transition here would be visible as a jump.
        pageBuilder: (_, state) =>
            _instant(state, OnboardingPage(onDone: prefs.setOnboardingSeen)),
      ),
      GoRoute(
        path: Routes.phone,
        pageBuilder: (_, state) => _fade(state, const PhonePage()),
      ),
      GoRoute(
        path: Routes.code,
        builder: (_, state) =>
            CodePage(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
        path: Routes.registrationProfile,
        pageBuilder: (_, state) =>
            _fade(state, const RegistrationProfilePage()),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (_, state, navigationShell) =>
            _fade(state, MainShell(navigationShell: navigationShell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.cart, builder: (_, _) => const CartPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.orders,
                builder: (_, _) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const MorePage()),
            ],
          ),
        ],
      ),
      // Outside the shell: these open over the tab bar.
      GoRoute(
        path: Routes.myQr,
        // A sheet over frosted glass, the app visible behind it.
        pageBuilder: (_, state) => myQrPage(
          state.pageKey,
          orderId: state.uri.queryParameters['order'],
        ),
      ),
      GoRoute(
        path: Routes.orderPattern,
        builder: (_, state) =>
            OrderPage(orderId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.legalPattern,
        builder: (_, state) => LegalPage(
          type:
              LegalDocumentType.values
                  .asNameMap()[state.pathParameters['type']] ??
              LegalDocumentType.terms,
        ),
      ),
      GoRoute(
        path: Routes.dishPattern,
        builder: (_, state) => DishPage(
          dishId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          // The menu passes the dish it has; after a restart it is null
          // and the screen loads the dish by id.
          initial: state.extra is Dish ? state.extra! as Dish : null,
        ),
      ),
      GoRoute(path: Routes.checkout, builder: (_, _) => const CheckoutPage()),
      GoRoute(
        path: Routes.myProfile,
        builder: (_, _) => MyProfilePage(onSignOut: signOut),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: Routes.faq, builder: (_, _) => const FaqPage()),
      GoRoute(path: Routes.support, builder: (_, _) => const SupportPage()),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationsPage(),
      ),
    ],
  );
}

Page<void> _instant(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);

Page<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 250),
  // Once the fade is over the page is drawn without an opacity layer:
  // Impeller cannot pass inherited opacity to blurred shadows, and a
  // leftover layer at 100 % made it complain on every repainted frame.
  transitionsBuilder: (context, animation, _, child) =>
      animation.isCompleted || MediaQuery.disableAnimationsOf(context)
      ? child
      : FadeTransition(opacity: animation, child: child),
);
