import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../session/session_repository.dart';
import 'auth_interceptor.dart';

/// Creates the Dio client for the API: the access token is added to every
/// request and renewed on 401 (see [AuthInterceptor]).
Dio createDio({required String baseUrl, required SessionRepository session}) {
  final dio = Dio(_options(baseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      session: session,
      dio: dio,
      refreshDio: Dio(_options(baseUrl)),
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (line) => debugPrint(line.toString()),
      ),
    );
  }
  return dio;
}

BaseOptions _options(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 15),
  sendTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Accept': 'application/json'},
);
