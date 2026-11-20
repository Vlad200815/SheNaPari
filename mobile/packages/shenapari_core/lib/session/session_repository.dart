import 'auth_tokens.dart';
import 'session_status.dart';

/// The single source of truth about authorization. The router listens to
/// [statusChanges] and redirects by itself, so nobody navigates manually
/// after sign-in or sign-out.
abstract interface class SessionRepository {
  SessionStatus get status;

  /// Emits only when the status actually changes.
  Stream<SessionStatus> get statusChanges;

  AuthTokens? get tokens;

  /// Reads the stored session on app start.
  Future<void> restore();

  /// Stores tokens after a successful sign-in.
  Future<void> save(AuthTokens tokens, {required bool isNewUser});

  /// Stores a rotated token pair after a refresh; the status is unchanged.
  Future<void> updateTokens(AuthTokens tokens);

  /// Marks the profile as filled in: needsProfile → authenticated.
  Future<void> completeProfile();

  /// Removes the session (sign-out or a rejected refresh).
  Future<void> clear();
}
