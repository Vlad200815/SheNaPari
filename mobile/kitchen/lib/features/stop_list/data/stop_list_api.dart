import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shenapari_core/network/api_envelope.dart';

import 'dto/stop_list_dtos.dart';

part 'stop_list_api.g.dart';

@RestApi()
abstract class StopListApi {
  factory StopListApi(Dio dio) = _StopListApi;

  @GET('/staff/dishes')
  Future<ApiEnvelope<List<StaffDishDto>>> getDishes();

  @GET('/categories')
  Future<ApiEnvelope<List<CategoryDto>>> getCategories();

  @PATCH('/staff/dishes/{id}/availability')
  Future<ApiEnvelope<StaffDishDto>> setAvailability(
    @Path('id') int id,
    @Body() SetAvailabilityDto body,
  );
}
