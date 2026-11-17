import 'dart:async';
import 'dart:developer' as developer;

import '../storage/token_storage.dart';
import 'auth_tokens.dart';
import 'session_repository.dart';
import 'session_status.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._storage);

  final TokenStorage _storage;
  final _controller = StreamController<SessionStatus>.broadcast();

  SessionStatus _status = SessionStatus.unknown;
  AuthTokens? _tokens;

  @override
  SessionStatus get status => _status;

  @override
  Stream<SessionStatus> get statusChanges => _controller.stream;

  @override
  AuthTokens? get tokens => _tokens;

  @override
  Future<void> restore() async {
    StoredSession? stored;
    try {
      stored = await _storage.read();
    } catch (e, stackTrace) {
      // Unreadable storage must not lock the user out of the app.
      developer.log(
        'Failed to read the stored session',
        name: 'session',
        error: e,
        stackTrace: stackTrace,
      );
    }
    _tokens = stored?.tokens;
    _setStatus(switch (stored) {
      null => SessionStatus.unauthenticated,
      StoredSession(needsProfile: true) => SessionStatus.needsProfile,
      _ => SessionStatus.authenticated,
    });
  }

  @override
  Future<void> save(AuthTokens tokens, {required bool isNewUser}) async {
    await _storage.write(
      StoredSession(tokens: tokens, needsProfile: isNewUser),
    );
    _tokens = tokens;
    _setStatus(
      isNewUser ? SessionStatus.needsProfile : SessionStatus.authenticated,
    );
  }

  @override
  Future<void> updateTokens(AuthTokens tokens) async {
    if (_tokens == null) return;
    await _storage.write(
      StoredSession(
        tokens: tokens,
        needsProfile: _status == SessionStatus.needsProfile,
      ),
    );
    _tokens = tokens;
  }

  @override
  Future<void> completeProfile() async {
    final tokens = _tokens;
    if (tokens == null) return;
    await _storage.write(StoredSession(tokens: tokens, needsProfile: false));
    _setStatus(SessionStatus.authenticated);
  }

  @override
  Future<void> clear() async {
    await _storage.clear();
    _tokens = null;
    _setStatus(SessionStatus.unauthenticated);
  }

  Future<void> dispose() => _controller.close();

  void _setStatus(SessionStatus status) {
    if (status == _status) return;
    _status = status;
    _controller.add(status);
  }
}
