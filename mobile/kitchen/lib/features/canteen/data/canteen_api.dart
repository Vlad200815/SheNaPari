import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shenapari_core/network/api_envelope.dart';

import 'dto/canteen_dtos.dart';

part 'canteen_api.g.dart';

@RestApi()
abstract class CanteenApi {
  factory CanteenApi(Dio dio) = _CanteenApi;

  @GET('/canteen')
  Future<ApiEnvelope<CanteenDto>> get();

  @PUT('/staff/canteen/accepting')
  Future<ApiEnvelope<CanteenDto>> setAccepting(@Body() SetAcceptingDto body);
}
