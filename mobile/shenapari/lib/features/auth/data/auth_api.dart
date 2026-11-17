import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_envelope.dart';
import 'dto/auth_dtos.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/auth/otp/request')
  Future<ApiEnvelope<Object?>> requestCode(@Body() OtpRequestDto body);

  @POST('/auth/otp/verify')
  Future<ApiEnvelope<AuthResponseDto>> verifyCode(@Body() OtpVerifyDto body);

  @POST('/auth/logout')
  Future<ApiEnvelope<Object?>> logout(@Body() RefreshDto body);
}
