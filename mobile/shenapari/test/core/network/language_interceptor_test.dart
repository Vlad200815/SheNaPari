import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/network/language_interceptor.dart';

void main() {
  test('every request says which language the app shows', () async {
    var language = 'uk';
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..interceptors.add(LanguageInterceptor(() => language))
      ..httpClientAdapter = _Echo();

    final first = await dio.get<String>('/menu');
    language = 'en';
    final second = await dio.get<String>('/menu');

    expect(first.data, 'uk');
    expect(second.data, 'en', reason: 'read on each request, not once');
  });
}

/// Answers with the request's Accept-Language.
class _Echo implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    options.headers['Accept-Language'] as String,
    200,
  );

  @override
  void close({bool force = false}) {}
}
