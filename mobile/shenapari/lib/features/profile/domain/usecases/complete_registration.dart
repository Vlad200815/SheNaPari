import '../../../../core/result/result.dart';
import '../../../../core/session/session_repository.dart';
import '../profile_repository.dart';

/// Saves the name of a new customer, then marks the profile as filled in.
/// The order matters: if the name is not saved, the user must stay on the
/// registration screen (the server would still say `isNew` next time).
class CompleteRegistration {
  CompleteRegistration(this._profile, this._session);

  final ProfileRepository _profile;
  final SessionRepository _session;

  Future<Result<void>> call({required String name}) async {
    switch (await _profile.updateName(name.trim())) {
      case Ok():
        // The router leaves the registration screen by itself.
        await _session.completeProfile();
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }
}
