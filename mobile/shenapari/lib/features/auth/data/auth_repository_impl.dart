import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/entities/sign_in.dart';
import 'auth_api.dart';
import 'dto/auth_dtos.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final AuthApi _api;

  @override
  Future<Result<void>> requestCode({required String phone}) =>
      apiCallVoid(() => _api.requestCode(OtpRequestDto(phone: phone)));

  @override
  Future<Result<SignIn>> verifyCode({
    required String phone,
    required String code,
  }) => apiCall(
    () => _api.verifyCode(OtpVerifyDto(phone: phone, code: code)),
    (dto) => dto.toEntity(),
  );

  @override
  Future<Result<void>> logout({required String refreshToken}) =>
      apiCallVoid(() => _api.logout(RefreshDto(refreshToken: refreshToken)));
}
