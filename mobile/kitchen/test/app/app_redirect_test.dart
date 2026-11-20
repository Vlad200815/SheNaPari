import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/app/router/app_redirect.dart';
import 'package:kitchen/app/router/routes.dart';
import 'package:shenapari_core/session/session_status.dart';

void main() {
  String? go(SessionStatus status, String location) =>
      appRedirect(status: status, location: location);

  test('while the session is read: the splash', () {
    expect(go(SessionStatus.unknown, Routes.queue), Routes.splash);
  });

  test('signed out: always the sign-in', () {
    expect(go(SessionStatus.unauthenticated, Routes.queue), Routes.login);
    expect(go(SessionStatus.unauthenticated, Routes.login), isNull);
  });

  test('signed in: from the splash or the sign-in to the queue', () {
    expect(go(SessionStatus.authenticated, Routes.splash), Routes.queue);
    expect(go(SessionStatus.authenticated, Routes.login), Routes.queue);
    expect(go(SessionStatus.authenticated, Routes.queue), isNull);
    expect(go(SessionStatus.needsProfile, Routes.login), Routes.queue);
  });
}
