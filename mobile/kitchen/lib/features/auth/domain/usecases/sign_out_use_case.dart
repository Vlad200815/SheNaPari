import 'package:shenapari_core/session/session_repository.dart';

import '../staff_auth_repository.dart';

/// Revokes the refresh token on the server and clears the local session.
/// The session is cleared even when the request fails: the employee asked
/// to sign out, and the token expires on the server anyway.
class SignOutUseCase {
  SignOutUseCase(this._auth, this._session);

  final StaffAuthRepository _auth;
  final SessionRepository _session;

  Future<void> call() async {
    final refreshToken = _session.tokens?.refreshToken;
    if (refreshToken != null) await _auth.logout(refreshToken: refreshToken);
    await _session.clear();
  }
}
