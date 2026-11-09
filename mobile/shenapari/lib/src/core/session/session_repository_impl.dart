import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/session/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;

  static const String accessStorageKey = "secure_access_token";
  static const String refreshStorageKey = "secure_refresh_token";
  static const String needsProfileKey = "needsProfile";

  SessionRepositoryImpl(this._storage, this._prefs);

  SessionStatus _status = SessionStatus.unauthenticated;

  @override
  // TODO: implement changes
  Stream<SessionStatus> get changes => throw UnimplementedError();

  @override
  Future<void> init() async {
    final refreshToken = await _storage.read(key: refreshStorageKey);
    final bool needsProfile = _prefs.getBool(needsProfileKey) ?? false;

    if (!refreshToken.isNullOrEmpty()) {
      if (needsProfile) {
        _status = SessionStatus.needsProfile;
        return;
      }
      _status = SessionStatus.authenticated;
      return;
    }

    _status = SessionStatus.unauthenticated;
  }

  @override
  // TODO: implement current
  SessionStatus get current => _status;

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> completeProfile() {
    // TODO: implement completeProfile
    throw UnimplementedError();
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool needsProfile,
  }) {
    // TODO: implement saveTokens
    throw UnimplementedError();
  }

  @override
  Future<String?> validAccessToken() {
    // TODO: implement validAccessToken
    throw UnimplementedError();
  }
}
