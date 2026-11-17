import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_repository.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/ui/placeholder_page.dart';
import '../../features/auth/presentation/code/code_page.dart';
import '../../features/auth/presentation/phone/phone_page.dart';
import '../../features/menu/presentation/home/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile/profile_page.dart';
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
              GoRoute(
                path: Routes.cart,
                builder: (_, _) => const PlaceholderPage(
                  title: 'Кошик',
                  note: 'Кошик з’явиться на наступному кроці',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.orders,
                builder: (_, _) => const PlaceholderPage(
                  title: 'Замовлення',
                  note: 'Історія замовлень з’явиться на кроці із замовленнями',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => ProfilePage(onSignOut: signOut),
              ),
            ],
          ),
        ],
      ),
      // Outside the shell: these open over the tab bar.
      GoRoute(
        path: Routes.myQr,
        pageBuilder: (_, state) => MaterialPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const PlaceholderPage(
            title: 'Мій QR',
            note: 'Немає активних замовлень',
          ),
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const PlaceholderPage(
          title: 'Сповіщення',
          note: 'Тут з’являться зміни статусу ваших замовлень',
        ),
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
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);
