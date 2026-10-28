import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

class DeviceHeadersInterceptor extends Interceptor {
  final String deviceIdHeaderKey = "X-Device-Id";
  final String platformHeaderKey = "X-Platform";
  final String languageHeaderKey = "X-Language";

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final fcmToken = await AppPreference.fcmToken;

    if (fcmToken.isNotEmpty) {
      options.headers[deviceIdHeaderKey] = fcmToken;
    } else {
      options.headers[deviceIdHeaderKey] = "device-token-1";
    }

    options.headers[platformHeaderKey] = Platform.operatingSystem;

    final language = await AppPreference.language;

    if (language.isNotEmpty == true) {
      options.headers["X-Language"] = language.split("_").firstOrNull;
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    handler.next(options);
  }
}
