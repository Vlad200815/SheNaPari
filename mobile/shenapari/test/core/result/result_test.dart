import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';

void main() {
  group('Result', () {
    test('Ok holds the value', () {
      const Result<int> result = Ok(42);

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 42);
    });

    test('Err holds the failure', () {
      const Result<int> result = Err(NetworkFailure());

      expect(result, isA<Err<int>>());
      expect((result as Err<int>).failure, isA<NetworkFailure>());
    });

    test('switch over Result is exhaustive without a default branch', () {
      String describe(Result<int> result) => switch (result) {
        Ok(:final value) => 'ok:$value',
        Err(:final failure) => 'err:${failure.message}',
      };

      expect(describe(const Ok(1)), 'ok:1');
      expect(
        describe(const Err(NotFoundFailure('Не знайдено'))),
        'err:Не знайдено',
      );
    });

    test('Ok values are equal when their values are equal', () {
      expect(const Ok(1), const Ok(1));
      expect(const Ok(1), isNot(const Ok(2)));
      expect(const Ok(1).hashCode, const Ok(1).hashCode);
    });

    test('Err values are equal when their failures are equal', () {
      expect(
        const Err<int>(ConflictFailure('Конфлікт')),
        const Err<int>(ConflictFailure('Конфлікт')),
      );
      expect(
        const Err<int>(ConflictFailure('Конфлікт')),
        isNot(const Err<int>(NotFoundFailure('Конфлікт'))),
      );
    });

    test('Ok and Err are never equal', () {
      expect(
        const Ok<Object>(NetworkFailure()),
        isNot(const Err<Object>(NetworkFailure())),
      );
    });
  });
}
