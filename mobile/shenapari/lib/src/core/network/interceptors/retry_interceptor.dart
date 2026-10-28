import 'package:dio/dio.dart';
import 'package:shenapari/src/core/network/api.dart';

class RetryInterceptor extends Interceptor {
  final Dio _retryDio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = Api.DEFAULT_MAX_RETRIES,
    this.retryDelay = Api.RETRY_DELAY,
  }) : _retryDio = Dio(Api.BASE_DIO_OPTIONS);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt =
        err.requestOptions.extra[Api.RETRY_ATTEMPT_KEY] as int? ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra[Api.RETRY_ATTEMPT_KEY] = attempt + 1;

    // Exponential backoff: 2s → 4s → 6s
    await Future.delayed(retryDelay * (attempt + 1));

    try {
      final response = await _retryDio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  /// Should Retry, check all possible error from which we could consider to retry
  bool _shouldRetry(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.sendTimeout => true,
      DioExceptionType.connectionError => true,
      _ => err.response?.statusCode == 503,
    };
  }
}
