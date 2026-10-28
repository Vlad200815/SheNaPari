import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/network/api.dart';
import 'package:shenapari/src/core/network/interceptors/auth_interceptor.dart';
import 'package:shenapari/src/core/network/interceptors/device_headers_interceptor.dart';

import 'retry_interceptor.dart';

class DioBuilder extends DioMixin implements Dio {
  final String contentType = Api.CONTENT_TYPE_JSON;

  static DioBuilder getInstance() => DioBuilder._();

  DioBuilder._() {
    options = BaseOptions(
      baseUrl: Config.BASE_URL,
      contentType: contentType,
      connectTimeout: Api.BASE_TIMEOUT,
      receiveTimeout: Api.BASE_TIMEOUT,
      sendTimeout: Api.BASE_TIMEOUT,
    );

    // Add custom interceptors
    interceptors.addAll([
      DeviceHeadersInterceptor(),
      AuthInterceptor(),
      RetryInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          /*if(options.path.contains('/posts')){
              return false;
            }*/
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    ]);

    httpClientAdapter = IOHttpClientAdapter();
  }
}
