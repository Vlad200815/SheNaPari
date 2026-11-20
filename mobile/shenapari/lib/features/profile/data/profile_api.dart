import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:shenapari_core/network/api_envelope.dart';
import 'dto/me_dto.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio) = _ProfileApi;

  @GET('/me')
  Future<ApiEnvelope<MeDto>> getMe();

  @PATCH('/me')
  Future<ApiEnvelope<MeDto>> updateMe(@Body() UpdateMeDto body);

  @PUT('/me/settings')
  Future<ApiEnvelope<MeDto>> updateSettings(@Body() MeSettingsDto body);

  @DELETE('/me')
  Future<ApiEnvelope<void>> deleteMe();
}
