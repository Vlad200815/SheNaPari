import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/network/api.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/features/auth/data/models/auth.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _refreshDio;

  AuthInterceptor() : _refreshDio = Dio(Api.BASE_DIO_OPTIONS);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await AppSecureStorage.getAccessToken();

    if (accessToken.isNullOrEmpty()) {
      handler.next(options);
      return;
    }

    final needsRefresh = _isTokenExpired(accessToken);

    if (needsRefresh) {
      final newAccessToken = await _refreshToken();

      if (newAccessToken == null) {
        await AppPreference.setAuthenticated(false);
        authNotifier.value = false;

        handler.reject(
          DioException(
            requestOptions: options,
            message: Api.EXPIRE_TOKEN_MESSAGE,
          ),
        );
        return;
      }

      options.headers[Api.AUTHORIZATION_HEADER_KEY] =
          "${Api.BEARER} $newAccessToken";
    } else {
      options.headers[Api.AUTHORIZATION_HEADER_KEY] =
          "${Api.BEARER} $accessToken";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If it is 401 error => try to refresh access token
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Try to refresh tokens
    final newAccessToken = await _refreshToken();

    // Check newly refresh token
    if (newAccessToken == null) {
      await AppPreference.setAuthenticated(false);
      authNotifier.value = false;

      handler.next(err);
      return;
    }

    // Set refresh access token to headers
    err.requestOptions.headers[Api.AUTHORIZATION_HEADER_KEY] =
        "${Api.BEARER} $newAccessToken";

    try {
      // Retry the failed call and try to resolve it
      final response = await _refreshDio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      // Pass the main [err] if everything failed
      handler.next(err);
    }
  }

  /// Checks if token is valid
  bool _isTokenExpired(String token) {
    try {
      // Decode access token
      final jwt = JWT.decode(token);
      // Get exp from the second part of jwt access token
      // It's how many seconds from 1970 year + (15 min == 900 seconds)
      final exp = jwt.payload[Api.EXPIRE_JWT] as int?;

      if (exp == null) return false;

      // Multiply by 1000 because [fromMillisecondsSinceEpoch] in milliseconds
      // 1 second equals to 1000 milliseconds
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      // +5 seconds not to get 401 error (expire token) at the last moment
      return expirationDate.isBefore(
        DateTime.now().add(const Duration(seconds: 5)),
      );
    } catch (_) {
      // If we can't read the token we consider it is expired
      return true;
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await AppSecureStorage.getRefreshToken();

      if (refreshToken.isNullOrEmpty()) return null;

      final Response<dynamic> response = await _refreshDio.post(
        Api.URL_AUTH_REFRESH,
        data: RefreshJwtRequest(refreshToken: refreshToken).toJson(),
      );

      final jwt = JWTResponse.fromJson(response.data as Map<String, dynamic>);

      if (jwt.accessToken.isNullOrEmpty() || jwt.refreshToken.isNullOrEmpty()) {
        return null;
      }

      await AppSecureStorage.saveTokens(
        accessToken: jwt.accessToken.orEmpty(),
        refreshToken: jwt.refreshToken.orEmpty(),
      );
      return jwt.accessToken.orEmpty();
    } catch (e) {
      await AppSecureStorage.deleteTokens();
      return null;
    }
  }
}
