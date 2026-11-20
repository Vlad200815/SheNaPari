import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';

abstract interface class StaffAuthRepository {
  /// E-mail and password the admin gave out. A wrong pair is a 401 with
  /// `auth.invalid_credentials`; a deactivated employee gets 403.
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout({required String refreshToken});
}
