import '../../../../core/result/result.dart';
import '../../../../core/session/session_repository.dart';
import '../auth_repository.dart';

/// Checks the code and, only on success, stores the session.
///
/// Nobody navigates afterwards: the session status changes
/// (needsProfile or authenticated) and the router redirects by itself.
class VerifyCodeUseCase {
  VerifyCodeUseCase(this._auth, this._session);

  final AuthRepository _auth;
  final SessionRepository _session;

  Future<Result<void>> call({
    required String phone,
    required String code,
  }) async {
    switch (await _auth.verifyCode(phone: phone, code: code)) {
      case Ok(value: final signIn):
        await _session.save(signIn.tokens, isNewUser: signIn.isNewUser);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }
}
