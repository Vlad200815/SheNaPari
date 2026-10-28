import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:shenapari/src/core/network/api.dart';
import 'package:shenapari/src/features/profile/data/models/update_name_request.dart';

part 'profile_api_service.g.dart';

@RestApi()
abstract class ProfileApiService {
  factory ProfileApiService(Dio dioBuilder) = _ProfileApiService;

  ///
  /// PROFILE
  ///
  @PATCH(Api.URL_PROFILE_NAME)
  Future<HttpResponse<dynamic>> updateName(@Body() UpdateNameRequest body);
}
