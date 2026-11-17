import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../session/auth_tokens.dart';
import 'token_storage.dart';

/// Stores the session in Keychain (iOS) / Keystore-encrypted storage (Android).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _needsProfileKey = 'needs_profile';

  @override
  Future<StoredSession?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return StoredSession(
      tokens: AuthTokens(accessToken: access, refreshToken: refresh),
      needsProfile: await _storage.read(key: _needsProfileKey) == 'true',
    );
  }

  @override
  Future<void> write(StoredSession session) async {
    await _storage.write(key: _accessKey, value: session.tokens.accessToken);
    await _storage.write(key: _refreshKey, value: session.tokens.refreshToken);
    await _storage.write(
      key: _needsProfileKey,
      value: session.needsProfile.toString(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _needsProfileKey);
  }
}
