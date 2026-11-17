import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/app/app.dart';
import 'package:shenapari/app/bootstrap.dart';
import 'package:shenapari/app/di.dart';
import 'package:shenapari/app/router/app_router.dart';
import 'package:shenapari/app/splash_page.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/core/storage/token_storage.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:shenapari/features/auth/presentation/widgets/code_field.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/onboarding/presentation/onboarding_page.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';

import '../fakes.dart';

const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
const _returning = {'launched_before': true, 'onboarding_seen': true};
const _phoneTitle = 'Введіть номер телефону';
const _codeTitle = 'Введіть 6-значний код';
const _nameTitle = 'Як вас звати?';

late FakeAuthRepository _auth;
late FakeProfileRepository _profile;

/// Starts the whole app the way bootstrap() does, with fake storage and
/// fake repositories instead of the network.
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  StoredSession? stored,
  Set<String> knownPhones = const {},
  bool settle = true,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final storage = InMemoryTokenStorage();
  if (stored != null) await storage.write(stored);

  await sl.reset();
  setupDi(prefs: await SharedPreferences.getInstance(), tokenStorage: storage);
  _auth = FakeAuthRepository(knownPhones: knownPhones);
  _profile = FakeProfileRepository();
  sl
    ..unregister<AuthRepository>()
    ..registerSingleton<AuthRepository>(_auth)
    ..unregister<ProfileRepository>()
    ..registerSingleton<ProfileRepository>(_profile)
    ..unregister<MenuRepository>()
    ..registerSingleton<MenuRepository>(FakeMenuRepository());

  await tester.pumpWidget(
    App(
      router: createRouter(
        session: sl(),
        prefs: sl(),
        signOut: sl<SignOutUseCase>().call,
      ),
    ),
  );
  expect(find.byType(SplashPage), findsOneWidget, reason: 'splash first');

  await startSession(session: sl(), tokenStorage: sl(), prefs: sl());
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _enterPhone(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '671234567');
  await tester.pump();
  await _tap(tester, 'Продовжити');
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(CodeField), code);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(sl.reset);

  testWidgets('first launch: onboarding → phone → code → name → home', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.byType(OnboardingPage), findsOneWidget);

    await _tap(tester, 'Пропустити');
    expect(find.text(_phoneTitle), findsOneWidget);

    await _enterPhone(tester);
    expect(find.text(_codeTitle), findsOneWidget);
    expect(find.textContaining('+380 67 123 45 67'), findsOneWidget);

    await _enterCode(tester, FakeAuthRepository.validCode);
    expect(find.text(_nameTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Влад');
    await tester.pump();
    await _tap(tester, 'Продовжити');

    expect(_profile.savedName, 'Влад');
    expect(find.byTooltip('Головна'), findsOneWidget);
  });

  testWidgets('splash is replaced by onboarding at once, without a slide', (
    tester,
  ) async {
    await _pumpApp(tester, settle: false);

    // With a page transition both screens would be on stage for a while.
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('returning customer skips the name step', (tester) async {
    await _pumpApp(tester, prefs: _returning, knownPhones: {'+380671234567'});

    await _enterPhone(tester);
    await _enterCode(tester, FakeAuthRepository.validCode);

    expect(find.text(_nameTitle), findsNothing);
    expect(find.byTooltip('Головна'), findsOneWidget);
  });

  testWidgets('wrong code shows the server message and stays', (tester) async {
    await _pumpApp(tester, prefs: _returning);
    await _enterPhone(tester);

    await _enterCode(tester, '000000');

    expect(find.text('Невірний або прострочений код'), findsOneWidget);
    expect(find.text(_codeTitle), findsOneWidget);
  });

  testWidgets('back from the code screen returns to the phone screen', (
    tester,
  ) async {
    await _pumpApp(tester, prefs: _returning);
    await _enterPhone(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(_phoneTitle), findsOneWidget);
  });

  testWidgets('stored session opens home right away', (tester) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    expect(find.byTooltip('Головна'), findsOneWidget);
    expect(find.text(_phoneTitle), findsNothing);
    expect(find.text('Чізбургер'), findsOneWidget, reason: 'menu is shown');
    expect(find.text('85 ₴'), findsOneWidget);
  });

  testWidgets('unfinished profile reopens the name step', (tester) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: true),
    );

    expect(find.text(_nameTitle), findsOneWidget);
  });

  testWidgets('sign-out revokes the token and returns to the phone screen', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    await tester.tap(find.byTooltip('Профіль'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Вийти');

    expect(find.text(_phoneTitle), findsOneWidget);
    expect(_auth.logoutCalls, 1);
    expect(await sl<TokenStorage>().read(), isNull);
  });

  group('delete account', () {
    Future<void> openDeleteDialog(WidgetTester tester) async {
      await _pumpApp(
        tester,
        prefs: _returning,
        stored: const StoredSession(tokens: _tokens, needsProfile: false),
      );
      await tester.tap(find.byTooltip('Профіль'));
      await tester.pumpAndSettle();
      await _tap(tester, 'Видалити акаунт');
      expect(find.text('Видалити акаунт?'), findsOneWidget);
    }

    testWidgets('cancel keeps the account', (tester) async {
      await openDeleteDialog(tester);

      await _tap(tester, 'Скасувати');

      expect(find.text('Видалити акаунт?'), findsNothing);
      expect(_profile.deleteCalls, 0);
      expect(await sl<TokenStorage>().read(), isNotNull);
    });

    testWidgets('confirm deletes and returns to the phone screen', (
      tester,
    ) async {
      await openDeleteDialog(tester);

      await _tap(tester, 'Видалити');

      expect(_profile.deleteCalls, 1);
      expect(find.text(_phoneTitle), findsOneWidget);
      expect(await sl<TokenStorage>().read(), isNull);
    });

    testWidgets('an active order: stays signed in and sees why', (
      tester,
    ) async {
      await openDeleteDialog(tester);
      _profile.deleteFailure = const ConflictFailure(
        'Спершу заберіть або скасуйте активне замовлення',
        code: 'profile.has_active_order',
      );

      await _tap(tester, 'Видалити');

      expect(
        find.text('Спершу заберіть або скасуйте активне замовлення'),
        findsOneWidget,
      );
      expect(find.text(_phoneTitle), findsNothing);
      expect(await sl<TokenStorage>().read(), isNotNull);
    });
  });

  testWidgets('first launch after reinstall ignores a leftover session', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(await sl<TokenStorage>().read(), isNull);
  });
}
