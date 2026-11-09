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

    test("needsProfile: false → current -> authenticated", () async {
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
}
