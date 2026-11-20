import 'package:kitchen/features/auth/domain/staff_auth_repository.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';

/// Accepts [email] / [password]; anything else is the server's 401.
class FakeStaffAuthRepository implements StaffAuthRepository {
  FakeStaffAuthRepository({
    this.email = 'cook@shenapari.local',
    this.password = 'Cook12345!',
  });

  final String email;
  final String password;
  final logouts = <String>[];

  static const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

  @override
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  }) async => email == this.email && password == this.password
      ? const Ok(tokens)
      : const Err(
          UnauthorizedFailure(
            'Невірний email або пароль',
            code: 'auth.invalid_credentials',
          ),
        );

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    logouts.add(refreshToken);
    return const Ok(null);
  }
}
