import '../../../../core/result/result.dart';
import '../../../../core/session/session_repository.dart';
import '../profile_repository.dart';

/// Deletes the account and, only if the server agreed, forgets the session.
///
/// Unlike sign-out, a failure keeps the session: the account still exists
/// (e.g. an active order blocks deletion), so the user stays signed in and
/// sees why. After success the router sends them to the phone screen.
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._profile, this._session);

  final ProfileRepository _profile;
  final SessionRepository _session;

  Future<Result<void>> call() async {
    final result = await _profile.deleteAccount();
    if (result is Ok) await _session.clear();
    return result;
  }
}
