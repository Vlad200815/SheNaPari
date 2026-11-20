import 'package:shenapari_core/session/session_status.dart';

import 'routes.dart';

/// Where the employee must be for the current session state; null to stay
/// on [location]. Pure, so it is easy to test.
String? appRedirect({required SessionStatus status, required String location}) {
  final target = switch (status) {
    SessionStatus.unknown => Routes.splash,
    SessionStatus.unauthenticated => Routes.login,
    // Staff have no profile to fill in: signed in means the kitchen.
    SessionStatus.needsProfile || SessionStatus.authenticated =>
      location == Routes.splash || location == Routes.login
          ? Routes.queue
          : location,
  };
  return target == location ? null : target;
}
