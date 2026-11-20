import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shenapari_core/network/api_envelope.dart';

import 'dto/staff_auth_dtos.dart';

part 'staff_auth_api.g.dart';

@RestApi()
abstract class StaffAuthApi {
  factory StaffAuthApi(Dio dio) = _StaffAuthApi;

  @POST('/auth/staff/login')
  Future<ApiEnvelope<AuthResponseDto>> login(@Body() StaffLoginDto body);

  @POST('/auth/logout')
  Future<ApiEnvelope<void>> logout(@Body() RefreshDto body);
}
