import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/entities/sign_in.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';

/// Accepts the code [validCode]; a number in [knownPhones] is a returning
/// customer, any other is new. Answers like the real backend.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.knownPhones = const {}});

  static const validCode = '123456';
  final Set<String> knownPhones;
  int logoutCalls = 0;

  @override
  Future<Result<void>> requestCode({required String phone}) async =>
      const Ok(null);

  @override
  Future<Result<SignIn>> verifyCode({
    required String phone,
    required String code,
  }) async {
    if (code != validCode) {
      return const Err(
        ValidationFailure(
          'Невірний або прострочений код',
          code: 'auth.invalid_code',
        ),
      );
    }
    return Ok(
      SignIn(
        tokens: const AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
        isNewUser: !knownPhones.contains(phone),
      ),
    );
  }

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    logoutCalls++;
    return const Ok(null);
  }
}

class FakeProfileRepository implements ProfileRepository {
  String? savedName;

  @override
  Future<Result<User>> getMe() async =>
      Ok(User(id: '1', role: UserRole.customer, name: savedName));

  @override
  Future<Result<User>> updateName(String name) async {
    savedName = name;
    return Ok(User(id: '1', role: UserRole.customer, name: name));
  }
}
