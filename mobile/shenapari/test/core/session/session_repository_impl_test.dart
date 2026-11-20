import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/session/auth_tokens.dart';
import 'package:shenapari_core/session/session_repository_impl.dart';
import 'package:shenapari_core/session/session_status.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';
import 'package:shenapari_core/storage/token_storage.dart';

const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

void main() {
  late InMemoryTokenStorage storage;
  late SessionRepositoryImpl session;

  setUp(() {
    storage = InMemoryTokenStorage();
    session = SessionRepositoryImpl(storage);
  });

  tearDown(() => session.dispose());

  test('starts as unknown until restored', () {
    expect(session.status, SessionStatus.unknown);
    expect(session.tokens, isNull);
  });

  group('restore', () {
    test('becomes unauthenticated when nothing is stored', () async {
      await session.restore();

      expect(session.status, SessionStatus.unauthenticated);
    });

    test('becomes authenticated when tokens are stored', () async {
      await storage.write(
        const StoredSession(tokens: _tokens, needsProfile: false),
      );

      await session.restore();

      expect(session.status, SessionStatus.authenticated);
      expect(session.tokens, _tokens);
    });

    test('becomes needsProfile when the profile was not finished', () async {
      await storage.write(
        const StoredSession(tokens: _tokens, needsProfile: true),
      );

      await session.restore();

      expect(session.status, SessionStatus.needsProfile);
    });

    test('becomes unauthenticated when storage fails', () async {
      storage.failOnRead = true;

      await session.restore();

      expect(session.status, SessionStatus.unauthenticated);
    });
  });

  group('save', () {
    test('existing user becomes authenticated and tokens are stored', () async {
      await session.save(_tokens, isNewUser: false);

      expect(session.status, SessionStatus.authenticated);
      expect(session.tokens, _tokens);
      expect((await storage.read())!.tokens, _tokens);
    });

    test('new user becomes needsProfile and the flag is stored', () async {
      await session.save(_tokens, isNewUser: true);

      expect(session.status, SessionStatus.needsProfile);
      expect((await storage.read())!.needsProfile, isTrue);
    });
  });

  group('updateTokens', () {
    test('replaces tokens and keeps the status', () async {
      await session.save(_tokens, isNewUser: true);
      const rotated = AuthTokens(accessToken: 'a2', refreshToken: 'r2');

      await session.updateTokens(rotated);

      expect(session.tokens, rotated);
      expect(session.status, SessionStatus.needsProfile);
      expect((await storage.read())!.tokens, rotated);
      expect((await storage.read())!.needsProfile, isTrue);
    });

    test('does nothing when there is no session', () async {
      await session.restore();

      await session.updateTokens(_tokens);

      expect(session.status, SessionStatus.unauthenticated);
      expect(await storage.read(), isNull);
    });
  });

  test('completeProfile turns needsProfile into authenticated', () async {
    await session.save(_tokens, isNewUser: true);

    await session.completeProfile();

    expect(session.status, SessionStatus.authenticated);
    expect((await storage.read())!.needsProfile, isFalse);
  });

  test('clear removes tokens and becomes unauthenticated', () async {
    await session.save(_tokens, isNewUser: false);

    await session.clear();

    expect(session.status, SessionStatus.unauthenticated);
    expect(session.tokens, isNull);
    expect(await storage.read(), isNull);
  });

  test('statusChanges emits every new status once', () async {
    final statuses = <SessionStatus>[];
    final sub = session.statusChanges.listen(statuses.add);

    await session.restore();
    await session.save(_tokens, isNewUser: true);
    await session.updateTokens(_tokens); // same status: no event
    await session.completeProfile();
    await session.clear();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(statuses, [
      SessionStatus.unauthenticated,
      SessionStatus.needsProfile,
      SessionStatus.authenticated,
      SessionStatus.unauthenticated,
    ]);
  });
}
