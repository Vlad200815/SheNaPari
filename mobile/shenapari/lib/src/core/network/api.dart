import 'package:dio/dio.dart';
import 'package:shenapari/src/app/config.dart';

class Api {
  const Api();

  ///
  /// Config
  ///

  // API ENDPOINTS

  //
  // Auth
  //
  static const URL_AUTH_SEND_OTP = "/auth/send-otp";
  static const URL_AUTH_RESEND_OTP = "/auth/resend-otp";
  static const URL_AUTH_VERIFY_OTP = "/auth/verify-otp";
  static const URL_AUTH_REFRESH = "/auth/refresh";

  //
  // Profile
  //

  static const URL_PROFILE_NAME = "/profile/name";

  //
  // General
  //

  static const EXPIRE_TOKEN_MESSAGE = 'Session expired. Please login again.';
  static const AUTHORIZATION_HEADER_KEY = "Authorization";
  static const BEARER = "Bearer";

  static const RETRY_ATTEMPT_KEY = "retryAttempt";

  static const BASE_TIMEOUT = Duration(seconds: 10);
  static const RETRY_DELAY = Duration(seconds: 2);
  static const DEFAULT_MAX_RETRIES = 3;

  static const CONTENT_TYPE_JSON = "application/json";

  static const EXPIRE_JWT = "exp";

  // Create a new instance everytime it is in use
  // As BaseOption is mutable
  static BaseOptions get BASE_DIO_OPTIONS => BaseOptions(
    baseUrl: Config.BASE_URL,
    contentType: CONTENT_TYPE_JSON,
    connectTimeout: BASE_TIMEOUT,
    receiveTimeout: BASE_TIMEOUT,
    sendTimeout: BASE_TIMEOUT,
  );
}
