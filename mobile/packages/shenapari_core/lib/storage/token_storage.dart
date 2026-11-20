import '../session/auth_tokens.dart';

/// What is kept on the device between app launches.
class StoredSession {
  const StoredSession({required this.tokens, required this.needsProfile});

  final AuthTokens tokens;
  final bool needsProfile;
}

/// Persistent storage for the session. The real one is backed by the
/// platform keystore; tests use the in-memory one.
abstract interface class TokenStorage {
  Future<StoredSession?> read();
  Future<void> write(StoredSession session);
  Future<void> clear();
}
