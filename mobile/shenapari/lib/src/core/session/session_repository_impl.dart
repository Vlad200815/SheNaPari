import 'dart:async';

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

  // Broadcast: several listeners (router redirect, SessionCubit, ...) may
  // subscribe at once; a single-subscription stream would throw.
  final _changes = StreamController<SessionStatus>.broadcast();

  @override
  Stream<SessionStatus> get changes => _changes.stream;

  /// Single place that updates the cache and notifies listeners,
  /// so the two can never get out of sync.
  void _setStatus(SessionStatus status) {
    if (status == _status) return;
    _status = status;
    _changes.add(status);
  }

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
  SessionStatus get current => _status;

  @override
  Future<void> clear() async {
    await _storage.delete(key: accessStorageKey);
    await _storage.delete(key: refreshStorageKey);
    await _prefs.remove(needsProfileKey);

    _setStatus(SessionStatus.unauthenticated);
  }

  @override
  Future<void> completeProfile() async {
    await _prefs.setBool(needsProfileKey, false);

    _setStatus(SessionStatus.authenticated);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool needsProfile,
  }) async {
    // Storage first: it is the source of truth. If a write throws,
    // _status must stay as it was so `current` never claims a session
    // that was not persisted.
    await _storage.write(key: accessStorageKey, value: accessToken);
    await _storage.write(key: refreshStorageKey, value: refreshToken);
    // Always write the flag (true AND false) so a stale `true` from a
    // previous session gets overwritten.
    await _prefs.setBool(needsProfileKey, needsProfile);

    _setStatus(
      needsProfile ? SessionStatus.needsProfile : SessionStatus.authenticated,
    );
  }

  @override
  Future<String?> validAccessToken() {
    // TODO: implement validAccessToken
    throw UnimplementedError();
  }
}
