import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/l10n/l10n.dart';
import 'package:shenapari/core/result/failure.dart';

void main() {
  group('Failure', () {
    test('NetworkFailure has a ready-to-show text', () {
      expect(const NetworkFailure().text, 'Немає з’єднання з сервером');
    });

    test('server-driven failures carry the message from the server', () {
      const failures = <Failure>[
        ValidationFailure('текст'),
        UnauthorizedFailure('текст'),
        ForbiddenFailure('текст'),
        NotFoundFailure('текст'),
        ConflictFailure('текст'),
        ServerFailure('текст'),
        UnexpectedFailure('текст'),
      ];

      for (final failure in failures) {
        expect(failure.message, 'текст', reason: '${failure.runtimeType}');
      }
    });

    test('failures from the server keep the error code', () {
      const failure = ValidationFailure(
        'Невірний або прострочений код',
        code: 'auth.invalid_code',
      );

      expect(failure.code, 'auth.invalid_code');
    });

    test('client-side failures have no code', () {
      expect(const NetworkFailure().code, isNull);
      expect(const UnexpectedFailure('x').code, isNull);
    });

    test('ServerFailure has no retryAfter by default', () {
      expect(const ServerFailure('Помилка').retryAfter, isNull);
    });

    test('ServerFailure keeps retryAfter for rate limiting', () {
      const failure = ServerFailure(
        'Забагато запитів',
        retryAfter: Duration(seconds: 30),
      );

      expect(failure.retryAfter, const Duration(seconds: 30));
    });

    test('switch over Failure is exhaustive without a default branch', () {
      String kind(Failure failure) => switch (failure) {
        NetworkFailure() => 'network',
        ValidationFailure() => 'validation',
        UnauthorizedFailure() => 'unauthorized',
        ForbiddenFailure() => 'forbidden',
        NotFoundFailure() => 'notFound',
        ConflictFailure() => 'conflict',
        ServerFailure() => 'server',
        UnexpectedFailure() => 'unexpected',
      };

      expect(kind(const ConflictFailure('x')), 'conflict');
    });

    group('equality', () {
      test('same type and message are equal', () {
        expect(const NotFoundFailure('a'), const NotFoundFailure('a'));
        expect(
          const NotFoundFailure('a').hashCode,
          const NotFoundFailure('a').hashCode,
        );
      });

      test('different message is not equal', () {
        expect(const NotFoundFailure('a'), isNot(const NotFoundFailure('b')));
      });

      test('different type with the same message is not equal', () {
        expect(const NotFoundFailure('a'), isNot(const ConflictFailure('a')));
      });

      test('different code is not equal', () {
        expect(
          const ConflictFailure('m', code: 'order.not_ready'),
          isNot(const ConflictFailure('m', code: 'order.cannot_cancel')),
        );
      });

      test('ServerFailure compares retryAfter', () {
        expect(
          const ServerFailure('m', retryAfter: Duration(seconds: 1)),
          const ServerFailure('m', retryAfter: Duration(seconds: 1)),
        );
        expect(
          const ServerFailure('m', retryAfter: Duration(seconds: 1)),
          isNot(const ServerFailure('m')),
        );
      });
    });
  });
}
