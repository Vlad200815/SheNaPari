import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_envelope.dart';
import 'dto/menu_dtos.dart';

part 'menu_api.g.dart';

@RestApi()
abstract class MenuApi {
  factory MenuApi(Dio dio) = _MenuApi;

  @GET('/canteen')
  Future<ApiEnvelope<CanteenDto>> getCanteen();

  @GET('/categories')
  Future<ApiEnvelope<List<CategoryDto>>> getCategories();

  @GET('/dishes')
  Future<ApiEnvelope<List<DishDto>>> getDishes();

  /// `data` is null when no break is scheduled.
  @GET('/breaks/next')
  Future<ApiEnvelope<BreakSlotDto>> getNextBreak();
}
