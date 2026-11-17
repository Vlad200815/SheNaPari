import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/network/auth_interceptor.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/session/session_repository_impl.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';

const _old = AuthTokens(accessToken: 'a1', refreshToken: 'r1');
const _new = AuthTokens(accessToken: 'a2', refreshToken: 'r2');

/// A tiny in-memory backend: `/me` accepts only the current access token,
/// `/auth/refresh` answers with whatever [refreshReply] returns.
class _FakeServer implements HttpClientAdapter {
  String validAccessToken = _old.accessToken;
  int refreshCalls = 0;
  final meAuthHeaders = <String?>[];

  /// Delays the refresh so parallel requests overlap in time.
  Completer<void>? refreshGate;

  /// Custom refresh answer; by default the server rotates the pair to a2/r2.
  Future<ResponseBody> Function()? refreshReply;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    switch (options.path) {
      case '/auth/refresh':
        refreshCalls++;
        await refreshGate?.future;
        final custom = refreshReply;
        if (custom != null) return custom();
        validAccessToken = _new.accessToken;
        return _refreshOk();
      case '/me':
        final header = options.headers['Authorization'] as String?;
        meAuthHeaders.add(header);
        return header == 'Bearer $validAccessToken'
            ? _json(200, {'succeeded': true, 'data': 'me', 'errors': []})
            : _json(401, {
                'succeeded': false,
                'message': 'Потрібно увійти в акаунт',
                'errors': ['common.unauthorized'],
              });
      default:
        return _json(404, {'succeeded': false});
    }
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _refreshOk() => _json(200, {
  'succeeded': true,
  'data': {'accessToken': 'a2', 'refreshToken': 'r2', 'isNew': false},
  'errors': <String>[],
});

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  late _FakeServer server;
  late SessionRepositoryImpl session;
  late Dio dio;

  setUp(() async {
    server = _FakeServer();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.restore();

    final refreshDio = Dio()..httpClientAdapter = server;
    dio = Dio()..httpClientAdapter = server;
    dio.interceptors.add(
      AuthInterceptor(session: session, dio: dio, refreshDio: refreshDio),
    );
  });

  tearDown(() => session.dispose());

  test('adds the access token to requests', () async {
    await session.save(_old, isNewUser: false);

    final response = await dio.get<dynamic>('/me');

    expect(response.statusCode, 200);
    expect(server.meAuthHeaders, ['Bearer a1']);
  });

  test('sends no header and never refreshes when signed out', () async {
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));

    expect(server.meAuthHeaders, [null]);
    expect(server.refreshCalls, 0);
  });

  test(
    'on 401 refreshes, stores the new pair and repeats the request',
    () async {
      await session.save(_old, isNewUser: false);
      server.validAccessToken = 'rotated-on-server';

      final response = await dio.get<dynamic>('/me');

      expect(response.statusCode, 200);
      expect(server.meAuthHeaders, ['Bearer a1', 'Bearer a2']);
      expect(session.tokens, _new);
      expect(session.status, SessionStatus.authenticated);
    },
  );

  test('parallel 401s share one refresh', () async {
    await session.save(_old, isNewUser: false);
    server.validAccessToken = 'expired';
    server.refreshGate = Completer<void>();

    final requests = Future.wait([
      dio.get<dynamic>('/me'),
      dio.get<dynamic>('/me'),
      dio.get<dynamic>('/me'),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    server.refreshGate!.complete();
    final responses = await requests;

    expect(responses.map((r) => r.statusCode), [200, 200, 200]);
    expect(server.refreshCalls, 1);
  });

  test('rejected refresh clears the session and returns the 401', () async {
    await session.save(_old, isNewUser: false);
    server.validAccessToken = 'expired';
    server.refreshReply = () async => _json(401, {
      'succeeded': false,
      'message': 'Сесія завершилась, увійдіть знову',
      'errors': ['auth.invalid_token'],
    });

    final error = await dio
        .get<dynamic>('/me')
        .then<DioException?>(
          (_) => null,
          onError: (Object e) => e as DioException,
        );

    expect(error?.response?.statusCode, 401);
    expect(session.status, SessionStatus.unauthenticated);
    expect(session.tokens, isNull);
  });

  test('refresh without network keeps the session', () async {
    await session.save(_old, isNewUser: false);
    server.validAccessToken = 'expired';
    server.refreshReply = () async => throw DioException(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      type: DioExceptionType.connectionError,
    );

    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));

    expect(session.status, SessionStatus.authenticated);
    expect(session.tokens, _old);
  });

  test('a second 401 after the refresh does not loop', () async {
    await session.save(_old, isNewUser: false);
    server.validAccessToken = 'never-valid';
    // The refresh succeeds, but /me still rejects the new token.
    server.refreshReply = () async => _refreshOk();

    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));

    expect(server.refreshCalls, 1);
    expect(server.meAuthHeaders, ['Bearer a1', 'Bearer a2']);
  });
}
