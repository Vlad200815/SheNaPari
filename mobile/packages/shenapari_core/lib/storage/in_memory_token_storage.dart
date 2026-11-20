import 'token_storage.dart';

/// Keeps the session in memory only. For tests.
class InMemoryTokenStorage implements TokenStorage {
  StoredSession? _session;

  /// Makes [read] throw, to simulate a broken keystore.
  bool failOnRead = false;

  @override
  Future<StoredSession?> read() async {
    if (failOnRead) throw StateError('storage is unavailable');
    return _session;
  }

  @override
  Future<void> write(StoredSession session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
