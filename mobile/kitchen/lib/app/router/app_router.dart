import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/session/session_repository.dart';

import '../../features/auth/presentation/login/login_page.dart';
import '../../features/queue/presentation/queue_page.dart';
import 'app_redirect.dart';
import 'routes.dart';

/// Nobody navigates after sign-in or sign-out: the router listens to the
/// session and redirects by itself.
GoRouter createRouter({
  required SessionRepository session,
  required Future<void> Function() signOut,
}) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: _StreamListenable(session.statusChanges),
  redirect: (_, state) =>
      appRedirect(status: session.status, location: state.matchedLocation),
  routes: [
    GoRoute(path: Routes.splash, builder: (_, _) => const _Splash()),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
    GoRoute(
      path: Routes.queue,
      builder: (_, _) => QueuePage(onSignOut: signOut),
    ),
  ],
);

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
