import '../../core/session/session_status.dart';
import 'routes.dart';

/// Decides where the user must be for the current session state.
/// Returns null to stay on [location]. Pure function, so it is easy to test.
String? appRedirect({
  required SessionStatus status,
  required bool onboardingSeen,
  required String location,
}) {
  final target = switch (status) {
    SessionStatus.unknown => Routes.splash,
    SessionStatus.unauthenticated when !onboardingSeen => Routes.onboarding,
    SessionStatus.unauthenticated =>
      location.startsWith('/auth/') ? location : Routes.phone,
    SessionStatus.needsProfile => Routes.registrationProfile,
    SessionStatus.authenticated =>
      _entryScreens.contains(location) ? Routes.home : location,
  };
  return target == location ? null : target;
}

/// Screens a signed-in user has no reason to see.
const _entryScreens = {
  Routes.splash,
  Routes.onboarding,
  Routes.phone,
  Routes.code,
  Routes.registrationProfile,
};
