import '../../../../core/session/session_repository.dart';
import '../auth_repository.dart';

/// Revokes the refresh token on the server and clears the local session.
/// The session is cleared even when the request fails (no network): the
/// user asked to sign out, and the token expires on the server anyway.
class SignOut {
  SignOut(this._auth, this._session);

  final AuthRepository _auth;
  final SessionRepository _session;

  Future<void> call() async {
    final refreshToken = _session.tokens?.refreshToken;
    if (refreshToken != null) await _auth.logout(refreshToken: refreshToken);
    await _session.clear();
  }
}
