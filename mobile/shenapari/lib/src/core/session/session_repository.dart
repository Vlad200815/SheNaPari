enum SessionStatus { unauthenticated, needsProfile, authenticated }

abstract interface class SessionRepository {
  /// Current status of authentication session
  /// We use it to cache a status of auth session so we don't need to call Secure
  /// Storage every time, it takes more time and it is slower.
  SessionStatus get current;

  /// You can listen for auth changes
  Stream<SessionStatus> get changes;

  /// Use this method before runApp() method in main.dart file
  /// Call it only once so it took tokens from Secure Storage and cache them it memory
  /// So all of our manipulations with it could be better optimized.
  Future<void> init();

  /// Saves jwt tokens to Secure Storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool needsProfile,
  });

  /// Completes the profile registration and switches auth status to authenticated
  Future<void> completeProfile();

  /// Clears jwt tokens from Secure Storage and needsProfile
  /// It doesn't clear introShown because after log-out a user must not see the onboarding screen.
  Future<void> clear();

  /// 1. Returns valid access token (refreshes if it needs)
  /// 2. Returns null, if there are no tokens or service throw 400/401/403 errors
  /// 3. Throws an exception if it looses connection or 5xx, and it doesn't delete tokens
  Future<String?> validAccessToken();
}
