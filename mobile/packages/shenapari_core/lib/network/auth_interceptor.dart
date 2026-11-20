import 'package:dio/dio.dart';

import '../session/auth_tokens.dart';
import '../session/session_repository.dart';

/// Marks a request that was already repeated after a refresh, so a second
/// 401 does not start an endless loop.
const _retriedKey = 'auth_retried';

/// Puts the access token on every request and renews the session on 401.
///
/// - Parallel requests that get 401 wait for **one shared** refresh: the
///   server rotates refresh tokens, so a second refresh with the old token
///   would fail.
/// - The refresh goes through [_refreshDio], which has no interceptors,
///   so it can never call itself.
/// - Refresh rejected by the server (400/401/403): the session is cleared and
///   the router sends the user to sign-in by itself.
/// - Refresh failed for another reason (no network, 5xx, 429): the session is
///   kept and the original error goes to the caller.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionRepository session,
    required Dio dio,
    required Dio refreshDio,
  }) : _session = session,
       _dio = dio,
       _refreshDio = refreshDio;

  final SessionRepository _session;

  /// The client this interceptor belongs to; used to repeat a request.
  final Dio _dio;
  final Dio _refreshDio;

  /// The refresh in progress, shared by every request that waits for it.
  Future<_RefreshOutcome>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _session.tokens?.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final sentToken = _sentToken(request);
    if (err.response?.statusCode != 401 ||
        sentToken == null ||
        request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    // If the token changed while this request was in flight, another
    // request has already refreshed it: just repeat with the new one.
    if (_session.tokens?.accessToken == sentToken) {
      final outcome = await _refreshOnce();
      if (outcome == _RefreshOutcome.rejected) await _session.clear();
      if (outcome != _RefreshOutcome.refreshed) return handler.next(err);
    }
    if (_session.tokens == null) return handler.next(err);

    request.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<_RefreshOutcome> _refreshOnce() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<_RefreshOutcome> _refresh() async {
    final refreshToken = _session.tokens?.refreshToken;
    if (refreshToken == null) return _RefreshOutcome.rejected;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return _RefreshOutcome.failed;
      await _session.updateTokens(
        AuthTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        ),
      );
      return _RefreshOutcome.refreshed;
    } on DioException catch (e) {
      return switch (e.response?.statusCode) {
        400 || 401 || 403 => _RefreshOutcome.rejected,
        _ => _RefreshOutcome.failed,
      };
    } catch (_) {
      // Unexpected body: keep the session, the next request will try again.
      return _RefreshOutcome.failed;
    }
  }

  static String? _sentToken(RequestOptions request) {
    final header = request.headers['Authorization'];
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring('Bearer '.length);
  }
}

enum _RefreshOutcome { refreshed, rejected, failed }
