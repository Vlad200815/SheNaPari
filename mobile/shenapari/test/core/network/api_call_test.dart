import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/network/api_envelope.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';

final _options = RequestOptions(path: '/test');

void main() {
  group('apiCall', () {
    test('returns Ok with the converted data on success', () async {
      final result = await apiCall<int, String>(
        () async => const ApiEnvelope(succeeded: true, data: 7),
        (data) => 'n$data',
      );

      expect(result, const Ok('n7'));
    });

    test('returns Err with message and code when succeeded is false', () async {
      final result = await apiCall<int, String>(
        () async => const ApiEnvelope(
          succeeded: false,
          message: 'Не знайдено',
          errors: ['common.not_found'],
        ),
        (data) => 'n$data',
      );

      // A 2xx with succeeded=false: the status is unknown, text and code stay.
      expect(
        result,
        const Err<String>(
          ServerFailure('Не знайдено', code: 'common.not_found'),
        ),
      );
    });

    test(
      'returns ServerFailure when succeeded is false without an error',
      () async {
        final result = await apiCall<int, String>(
          () async => const ApiEnvelope(succeeded: false),
          (data) => 'n$data',
        );

        expect((result as Err<String>).failure, isA<ServerFailure>());
      },
    );

    test('returns UnexpectedFailure when success comes without data', () async {
      final result = await apiCall<int, String>(
        () async => const ApiEnvelope(succeeded: true),
        (data) => 'n$data',
      );

      expect((result as Err<String>).failure, isA<UnexpectedFailure>());
    });

    test('maps DioException through toFailure', () async {
      final result = await apiCall<int, String>(
        () async => throw DioException(
          requestOptions: _options,
          type: DioExceptionType.connectionTimeout,
        ),
        (data) => 'n$data',
      );

      expect(result, const Err<String>(NetworkFailure()));
    });

    test(
      'returns UnexpectedFailure when the request throws something else',
      () async {
        final result = await apiCall<int, String>(
          () async => throw const FormatException('bad json'),
          (data) => 'n$data',
        );

        expect((result as Err<String>).failure, isA<UnexpectedFailure>());
      },
    );

    test('returns UnexpectedFailure when the converter throws', () async {
      final result = await apiCall<int, String>(
        () async => const ApiEnvelope(succeeded: true, data: 7),
        (data) => throw StateError('mapper bug'),
      );

      expect((result as Err<String>).failure, isA<UnexpectedFailure>());
    });

    test('never shows technical details to the user', () async {
      final result = await apiCall<int, String>(
        () async => throw const FormatException('bad json'),
        (data) => 'n$data',
      );

      expect(
        (result as Err<String>).failure.message,
        isNot(contains('FormatException')),
      );
    });
  });

  group('apiCallVoid', () {
    test('returns Ok when success comes without data', () async {
      final result = await apiCallVoid(
        () async => const ApiEnvelope<void>(succeeded: true),
      );

      expect(result, isA<Ok<void>>());
    });

    test('returns Err mapped from the error', () async {
      final result = await apiCallVoid(
        () async => const ApiEnvelope<void>(
          succeeded: false,
          message: 'Сесія завершилась',
          errors: ['auth.invalid_token'],
        ),
      );

      expect(
        (result as Err<void>).failure,
        const ServerFailure('Сесія завершилась', code: 'auth.invalid_token'),
      );
    });

    test('maps DioException through toFailure', () async {
      final result = await apiCallVoid(
        () async => throw DioException(
          requestOptions: _options,
          type: DioExceptionType.connectionError,
        ),
      );

      expect((result as Err<void>).failure, const NetworkFailure());
    });
  });

  group('apiCallNullable', () {
    test('success without data is Ok(null), not a failure', () async {
      final result = await apiCallNullable<int, String>(
        () async => const ApiEnvelope<int>(succeeded: true),
        (data) => 'value $data',
      );

      expect(result, const Ok<String?>(null));
    });

    test('data is converted to the entity', () async {
      final result = await apiCallNullable<int, String>(
        () async => const ApiEnvelope<int>(succeeded: true, data: 5),
        (data) => 'value $data',
      );

      expect(result, const Ok<String?>('value 5'));
    });

    test('maps DioException through toFailure', () async {
      final result = await apiCallNullable<int, String>(
        () async => throw DioException(
          requestOptions: _options,
          type: DioExceptionType.connectionError,
        ),
        (data) => 'value $data',
      );

      expect((result as Err<String?>).failure, const NetworkFailure());
    });
  });
}
