import '../../../core/result/result.dart';
import 'entities/sign_in.dart';

abstract interface class AuthRepository {
  /// Sends an SMS code to [phone] (`+380XXXXXXXXX`). The server allows a new
  /// code once per 60 s (`auth.too_many_requests`).
  Future<Result<void>> requestCode({required String phone});

  /// Checks the 6-digit [code]. Wrong code: `auth.invalid_code`;
  /// 5 wrong attempts: `auth.too_many_attempts`.
  Future<Result<SignIn>> verifyCode({
    required String phone,
    required String code,
  });

  /// Revokes [refreshToken] on the server.
  Future<Result<void>> logout({required String refreshToken});
}
