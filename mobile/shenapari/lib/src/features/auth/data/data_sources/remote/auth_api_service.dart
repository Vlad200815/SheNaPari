import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:shenapari/src/core/network/api.dart';
import 'package:shenapari/src/features/auth/data/models/auth.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dioBuilder) = _AuthApiService;

  ///
  /// SEND-OTP
  ///
  @POST(Api.URL_AUTH_SEND_OTP)
  Future<HttpResponse<dynamic>> sendOtpCode(@Body() OtpRequest body);

  //TODO: try to use Result<T> here just instead of entities use dto models
  // ///
  // /// SEND-OTP
  // ///
  // @POST(Api.URL_AUTH_SEND_OTP)
  // Future<Result<OtpEntity>> sendOtpCode(@Body() OtpRequest body);

  ///
  /// RESEND-OTP
  ///
  @POST(Api.URL_AUTH_RESEND_OTP)
  Future<HttpResponse<dynamic>> resendOtpCode(@Body() OtpRequest body);

  ///
  /// VERIFY-OTP
  ///
  @POST(Api.URL_AUTH_VERIFY_OTP)
  Future<HttpResponse<dynamic>> verifyOtpCode(@Body() VerifyOtpRequest body);

  // ///
  // /// PROFILE
  // ///
  // @PATCH(Api.URL_PROFILE_NAME)
  // Future<HttpResponse<dynamic>> updateName(@Body() UpdateNameRequest body);

  // @GET(Api.URL_TITLES)
  // Future<MoviesData> getMovies({
  //   @Query(Api.SORT_BY) String? sortBy,
  //   @Query(Api.SORT_ORDER) String? sortOrder,
  //   @Query(Api.TYPES) List<String>? videoTypes,
  //   @Query(Api.GENRES) List<String>? videoGenres,
  //   @Query(Api.COUNTRY_CODES) List<String>? countryCodes,
  //   @Query(Api.START_YEAR) int? startYear,
  //   @Query(Api.END_YEAR) int? endYear,
  //   @Query(Api.PAGE_TOKEN) String? pageToken,
  // });
  //
  // ///
  // /// SEARCH
  // ///
  //
  // @GET(Api.URL_SEARCH_TITLES)
  // Future<MoviesData> searchMovies({
  //   @Query(Api.SEARCH) required String query,
  //   @Query(Api.LIMIT) int? limit,
  // });
  //
  // ///
  // /// DETAIL
  // ///
  //
  // @GET(Api.URL_TITLES_ID)
  // Future<MovieItem> getMovieById({@Path(Api.ID) required String titleId});
  //
  // ///
  // /// DETAIL IMAGES
  // ///
  //
  // @GET(Api.URL_TITLES_ID_IMAGES)
  // Future<MovieImgData> getMovieImages({@Path(Api.ID) required String titleId});
  //
  // ///
  // /// CAST
  // ///
  // @GET(Api.URL_TITLES_ID_CREDITS)
  // Future<CastData> getMovieCast({@Path(Api.ID) required String titleId});
  //
  // ///
  // /// PARENT GUIDE
  // ///
  // @GET(Api.URL_TITLES_ID_PARENT_GUIDE)
  // Future<ParentGuideData> getMovieParentGuide({
  //   @Path(Api.ID) required String titleId,
  // });
  //
  // ///
  // /// AWARDS
  // ///
  // @GET(Api.URL_TITLES_ID_AWARDS)
  // Future<AwardsData> getMovieAwards({@Path(Api.ID) required String titleId});
}
