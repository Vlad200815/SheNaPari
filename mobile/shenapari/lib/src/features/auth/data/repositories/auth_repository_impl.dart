import 'package:dio/dio.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/auth/data/data_sources/remote/auth_api_service.dart';
import 'package:shenapari/src/features/auth/data/models/auth.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';
import 'package:shenapari/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl({required AuthApiService apiService})
    : _authApiService = apiService;

  @override
  Future<Result<OtpEntity>> sendOtpCode({required String phoneNumber}) async {
    try {
      // Get raw data from AuthApiService
      final httpResponse = await _authApiService.sendOtpCode(
        // Put the right request model
        OtpRequest(phone: phoneNumber),
      );

      // Case raw data to Map<String, dynamic>
      final Map<String, dynamic> rawMap =
          httpResponse.data as Map<String, dynamic>;

      // Parse the map to Result<OtpResponse> dart object
      final resultModel = Result<OtpResponse>.fromJson(
        rawMap,
        // This is our T (generic type) parse OtpResponse to dart object
        (json) => OtpResponse.fromJson(json as Map<String, dynamic>),
      );

      // Put everything together
      return Result<OtpEntity>(
        succeeded: resultModel.succeeded,
        message: resultModel.message,
        data: resultModel.data?.toEntity(),
        errors: resultModel.errors,
      );
    } on DioException catch (dioError) {
      return _handleDioError(dioError);
    } catch (e) {
      return Result<OtpEntity>(succeeded: false, message: e.toString());
    }
  }

  @override
  Future<Result<OtpEntity>> resendOtpCode({required String phoneNumber}) async {
    try {
      final httpResponse = await _authApiService.resendOtpCode(
        OtpRequest(phone: phoneNumber),
      );

      final Map<String, dynamic> rawMap =
          httpResponse.data as Map<String, dynamic>;
      final resultModel = Result<OtpResponse>.fromJson(
        rawMap,
        (json) => OtpResponse.fromJson(json as Map<String, dynamic>),
      );

      return Result<OtpEntity>(
        succeeded: resultModel.succeeded,
        message: resultModel.message,
        data: resultModel.data?.toEntity(),
        errors: resultModel.errors,
      );
    } on DioException catch (dioError) {
      return _handleDioError(dioError);
    } catch (e) {
      return Result<OtpEntity>(succeeded: false, message: e.toString());
    }
  }

  @override
  Future<Result<JWTEntity>> verifyOtpCode({
    required String phoneNumber,
    required String otpCode,
    required String fcmToken,
  }) async {
    try {
      final httpResponse = await _authApiService.verifyOtpCode(
        VerifyOtpRequest(
          phone: phoneNumber,
          otpCode: otpCode,
          fcmToken: fcmToken,
        ),
      );

      final Map<String, dynamic> rawMap = httpResponse.data;

      final resultModel = Result<JWTResponse>.fromJson(
        rawMap,
        (json) => JWTResponse.fromJson(json as Map<String, dynamic>),
      );

      return Result<JWTEntity>(
        succeeded: resultModel.succeeded,
        message: resultModel.message,
        data: resultModel.data?.toEntity(),
        errors: resultModel.errors,
      );
    } on DioException catch (dioError) {
      return _handleDioError(dioError);
    } catch (e) {
      return Result<JWTEntity>(succeeded: false, message: e.toString());
    }
  }

  //TODO: read about dio error and how to handle them efficiently
  /// Centralized helper method to map backend Dio exceptions to your Result wrapper
  Result<E> _handleDioError<E>(DioException error) {
    final Map<String, dynamic>? errorData =
        error.response?.data as Map<String, dynamic>?;
    final backendMessage = errorData?['message'] as String?;
    final backendErrors = errorData?['errors'] as List<dynamic>?;

    return Result<E>(
      succeeded: false,
      message: backendMessage ?? "Network communication error occurred.",
      errors: backendErrors?.map((e) => e.toString()).toList(),
      data: null,
    );
  }
}
