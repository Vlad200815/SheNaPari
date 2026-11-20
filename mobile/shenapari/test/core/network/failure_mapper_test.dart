import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/network/api_envelope.dart';
import 'package:shenapari_core/network/failure_mapper.dart';
import 'package:shenapari_core/result/failure.dart';

final _options = RequestOptions(path: '/test');

DioException _badResponse(
  int status,
  Object? body, {
  Map<String, List<String>> headers = const {},
}) => DioException(
  requestOptions: _options,
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: _options,
    statusCode: status,
    data: body,
    headers: Headers.fromMap(headers),
  ),
);

Map<String, Object?> _errorBody(String message, String code) => {
  'succeeded': false,
  'message': message,
  'data': null,
  'errors': [code],
};

void main() {
  group('failureForStatus', () {
    final cases = <int?, Matcher>{
      400: isA<ValidationFailure>(),
      401: isA<UnauthorizedFailure>(),
      403: isA<ForbiddenFailure>(),
      404: isA<NotFoundFailure>(),
      409: isA<ConflictFailure>(),
      429: isA<ServerFailure>(),
      500: isA<ServerFailure>(),
      418: isA<ServerFailure>(),
      null: isA<ServerFailure>(),
    };

    cases.forEach((status, matcher) {
      test('$status maps to the expected failure', () {
        final failure = failureForStatus(status, 'текст', code: 'x.y');

        expect(failure, matcher);
        expect(failure.message, 'текст');
        expect(failure.code, 'x.y');
      });
    });
  });

  group('ApiEnvelope.toFailure', () {
    test('takes message and the first code', () {
      const env = ApiEnvelope<void>(
        succeeded: false,
        message: 'Невірний або прострочений код',
        errors: ['auth.invalid_code'],
      );

      expect(
        env.toFailure(status: 400),
        const ValidationFailure(
          'Невірний або прострочений код',
          code: 'auth.invalid_code',
        ),
      );
    });

    test('falls back to a generic message', () {
      const env = ApiEnvelope<void>(succeeded: false);

      expect(env.toFailure(status: 404).message, genericErrorMessage);
    });
  });

  group('DioException.toFailure', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.unknown,
    ]) {
      test('${type.name} without a response is NetworkFailure', () {
        final e = DioException(requestOptions: _options, type: type);

        expect(e.toFailure(), const NetworkFailure());
      });
    }

    test('cancel is UnexpectedFailure, not a network problem', () {
      final e = DioException(
        requestOptions: _options,
        type: DioExceptionType.cancel,
      );

      expect(e.toFailure(), isA<UnexpectedFailure>());
    });

    test('envelope body: decides by the HTTP status, keeps text and code', () {
      final e = _badResponse(
        409,
        _errorBody('Кухня зараз не приймає замовлення', 'order.canteen_paused'),
      );

      expect(
        e.toFailure(),
        const ConflictFailure(
          'Кухня зараз не приймає замовлення',
          code: 'order.canteen_paused',
        ),
      );
    });

    test('429 reads Retry-After seconds from the header', () {
      final e = _badResponse(
        429,
        _errorBody('Забагато запитів', 'common.too_many_requests'),
        headers: {
          'retry-after': ['30'],
        },
      );

      expect(
        e.toFailure(),
        const ServerFailure(
          'Забагато запитів',
          code: 'common.too_many_requests',
          retryAfter: Duration(seconds: 30),
        ),
      );
    });

    test('429 with a malformed Retry-After has no retryAfter', () {
      final e = _badResponse(
        429,
        _errorBody('x', 'common.too_many_requests'),
        headers: {
          'retry-after': ['soon'],
        },
      );

      expect((e.toFailure() as ServerFailure).retryAfter, isNull);
    });

    test('non-envelope body: decides by the HTTP status', () {
      expect(
        _badResponse(502, '<html>Bad Gateway</html>').toFailure(),
        isA<ServerFailure>(),
      );
      expect(_badResponse(401, null).toFailure(), isA<UnauthorizedFailure>());
      expect(
        _badResponse(404, {'message': 'x'}).toFailure(),
        isA<NotFoundFailure>(),
      );
    });

    test('non-envelope body: message is generic and there is no code', () {
      final failure = _badResponse(502, '<html></html>').toFailure();

      expect(failure.message, genericErrorMessage);
      expect(failure.code, isNull);
    });
  });
}
