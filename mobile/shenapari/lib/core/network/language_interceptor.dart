import 'package:dio/dio.dart';

/// Adds `Accept-Language` to every request, so the server's texts (error
/// messages, documents) come in the language the app shows.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._languageCode);

  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }
}
