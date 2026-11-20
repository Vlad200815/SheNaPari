import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';

import '../domain/staff_auth_repository.dart';
import 'dto/staff_auth_dtos.dart';
import 'staff_auth_api.dart';

class StaffAuthRepositoryImpl implements StaffAuthRepository {
  StaffAuthRepositoryImpl(this._api);

  final StaffAuthApi _api;

  @override
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  }) => apiCall(
    () => _api.login(StaffLoginDto(email: email, password: password)),
    (dto) => dto.toEntity(),
  );

  @override
  Future<Result<void>> logout({required String refreshToken}) =>
      apiCallVoid(() => _api.logout(RefreshDto(refreshToken: refreshToken)));
}
