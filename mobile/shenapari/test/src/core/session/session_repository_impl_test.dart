import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/src/core/session/session_repository.dart';
import 'package:shenapari/src/core/session/session_repository_impl.dart';

/// Keys
const String accessStorageKey = "secure_access_token";
const String refreshStorageKey = "secure_refresh_token";
const String needsProfileKey = "needsProfile";

/// Values
const String accessMockValue = "access123";
const String refreshMockValue = "refresh123";

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late SharedPreferences prefs;
  late SessionRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // in-memory prefs, без пристрою
    prefs = await SharedPreferences.getInstance();
    storage = MockSecureStorage();
    repo = SessionRepositoryImpl(storage, prefs);
  });

  group("init", () {
    setUp(() {
      when(
        () => storage.read(key: refreshStorageKey),
      ).thenAnswer((_) async => refreshMockValue);
    });

    test('no stored tokens → unauthenticated', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      await repo.init();
      expect(repo.current, SessionStatus.unauthenticated);
    });

    test('refresh token exists, needsProfile=true → needsProfile', () async {
      await prefs.setBool(needsProfileKey, true);

      await repo.init();

      expect(repo.current, SessionStatus.needsProfile);
    });

    test(
      'refresh token exists, no needsProfile flag → authenticated',
      () async {
        await repo.init();

        expect(repo.current, SessionStatus.authenticated);
      },
    );

    test('refresh exists, access missing → authenticated', () async {
      when(
        () => storage.read(key: accessStorageKey),
      ).thenAnswer((_) async => null);

      await repo.init();

      expect(repo.current, SessionStatus.authenticated);
    });
  });

  group("saveTokens", () {
    setUp(() {
      when(
        () => storage.write(
          key: any(named: "key"),
          value: any(named: "value"),
        ),
      ).thenAnswer((_) async {});
    });

    test('needsProfile=false overwrites previous true flag', () async {
      await prefs.setBool(needsProfileKey, true);

      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: false,
      );

      expect(prefs.getBool(needsProfileKey), false);
    });

    test('storage write fails → current stays unchanged', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('keychain locked'));

      await expectLater(
        repo.saveTokens(
          accessToken: accessMockValue,
          refreshToken: refreshMockValue,
          needsProfile: false,
        ),
        throwsException,
      );

      expect(repo.current, SessionStatus.unauthenticated);
    });

    test('needsProfile=false → current is authenticated', () async {
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: false,
      );

      expect(repo.current, SessionStatus.authenticated);
    });

    test('writes both tokens to storage', () async {
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: false,
      );

      verify(
        () => storage.write(key: accessStorageKey, value: accessMockValue),
      ).called(1);

      verify(
        () => storage.write(key: refreshStorageKey, value: refreshMockValue),
      ).called(1);
    });

    test("needsProfile=true → current is needsProfile", () async {
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: true,
      );

      expect(repo.current, SessionStatus.needsProfile);
    });

    test('persists needsProfile flag', () async {
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: true,
      );

      expect(prefs.getBool(needsProfileKey), true);
    });
  });

  group('clear', () {
    setUp(() async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Arrange a logged-in session to clear.
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: true,
      );
    });

    test('deletes both tokens from storage', () async {
      await repo.clear();

      verify(() => storage.delete(key: accessStorageKey)).called(1);
      verify(() => storage.delete(key: refreshStorageKey)).called(1);
    });

    test('removes needsProfile flag', () async {
      await repo.clear();

      expect(prefs.getBool(needsProfileKey), isNull);
    });

    test('current → unauthenticated', () async {
      await repo.clear();

      expect(repo.current, SessionStatus.unauthenticated);
    });
  });

  group('completeProfile', () {
    test('needsProfile session → authenticated, flag false', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: true,
      );

      await repo.completeProfile();

      expect(repo.current, SessionStatus.authenticated);
      expect(prefs.getBool(needsProfileKey), false);
    });
  });

  group('changes', () {
    setUp(() {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
    });

    test('emits every status transition in order', () async {
      // Subscribe BEFORE acting: a broadcast stream does not replay.
      final expectation = expectLater(
        repo.changes,
        emitsInOrder([
          SessionStatus.needsProfile,
          SessionStatus.authenticated,
          SessionStatus.unauthenticated,
        ]),
      );

      await repo.saveTokens(
        accessToken: accessMockValue,
        refreshToken: refreshMockValue,
        needsProfile: true,
      );
      await repo.completeProfile();
      await repo.clear();

      await expectation;
    });

    test('does not emit when status is unchanged', () async {
      final emitted = <SessionStatus>[];
      final sub = repo.changes.listen(emitted.add);

      await repo.clear(); // already unauthenticated
      await Future<void>.delayed(Duration.zero); // let the stream deliver

      expect(emitted, isEmpty);
      await sub.cancel();
    });
  });
}
