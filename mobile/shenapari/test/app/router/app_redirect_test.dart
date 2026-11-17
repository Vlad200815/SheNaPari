import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/app/router/app_redirect.dart';
import 'package:shenapari/app/router/routes.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';

String? _redirect(
  SessionStatus status,
  String location, {
  bool onboardingSeen = true,
}) => appRedirect(
  status: status,
  onboardingSeen: onboardingSeen,
  location: location,
);

void main() {
  group('unknown (session is being restored)', () {
    test('everything goes to splash', () {
      expect(_redirect(SessionStatus.unknown, Routes.home), Routes.splash);
      expect(_redirect(SessionStatus.unknown, Routes.phone), Routes.splash);
    });

    test('splash stays', () {
      expect(_redirect(SessionStatus.unknown, Routes.splash), isNull);
    });
  });

  group('unauthenticated', () {
    test('first launch goes to onboarding', () {
      expect(
        _redirect(
          SessionStatus.unauthenticated,
          Routes.splash,
          onboardingSeen: false,
        ),
        Routes.onboarding,
      );
    });

    test('onboarding stays until it is seen', () {
      expect(
        _redirect(
          SessionStatus.unauthenticated,
          Routes.onboarding,
          onboardingSeen: false,
        ),
        isNull,
      );
    });

    test('after onboarding goes to phone', () {
      expect(
        _redirect(SessionStatus.unauthenticated, Routes.onboarding),
        Routes.phone,
      );
      expect(
        _redirect(SessionStatus.unauthenticated, Routes.splash),
        Routes.phone,
      );
    });

    test('auth screens stay', () {
      expect(_redirect(SessionStatus.unauthenticated, Routes.phone), isNull);
      expect(_redirect(SessionStatus.unauthenticated, Routes.code), isNull);
    });

    test('legal documents open before signing in', () {
      for (final type in LegalDocumentType.values) {
        expect(
          _redirect(SessionStatus.unauthenticated, Routes.legal(type)),
          isNull,
        );
      }
    });

    test('protected screens go to phone', () {
      expect(
        _redirect(SessionStatus.unauthenticated, Routes.home),
        Routes.phone,
      );
      expect(
        _redirect(SessionStatus.unauthenticated, Routes.profile),
        Routes.phone,
      );
      expect(
        _redirect(SessionStatus.unauthenticated, Routes.registrationProfile),
        Routes.phone,
      );
    });
  });

  group('needsProfile', () {
    test('everything goes to registration profile', () {
      for (final location in [
        Routes.splash,
        Routes.code,
        Routes.home,
        Routes.profile,
      ]) {
        expect(
          _redirect(SessionStatus.needsProfile, location),
          Routes.registrationProfile,
          reason: location,
        );
      }
    });

    test('registration profile stays', () {
      expect(
        _redirect(SessionStatus.needsProfile, Routes.registrationProfile),
        isNull,
      );
    });
  });

  group('authenticated', () {
    test('entry screens go to home', () {
      for (final location in [
        Routes.splash,
        Routes.onboarding,
        Routes.phone,
        Routes.code,
        Routes.registrationProfile,
      ]) {
        expect(
          _redirect(SessionStatus.authenticated, location),
          Routes.home,
          reason: location,
        );
      }
    });

    test('main screens stay', () {
      expect(_redirect(SessionStatus.authenticated, Routes.home), isNull);
      expect(_redirect(SessionStatus.authenticated, Routes.profile), isNull);
    });
  });
}
