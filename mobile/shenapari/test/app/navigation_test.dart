import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/app/app.dart';
import 'package:shenapari/app/bootstrap.dart';
import 'package:shenapari/app/di.dart';
import 'package:shenapari/app/router/app_router.dart';
import 'package:shenapari/app/splash_page.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/core/storage/token_storage.dart';
import 'package:shenapari/features/onboarding/presentation/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

/// Starts the whole app with fake storage, the same way bootstrap() does.
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  StoredSession? stored,
  bool settle = true,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final storage = InMemoryTokenStorage();
  if (stored != null) await storage.write(stored);

  await sl.reset();
  setupDi(prefs: await SharedPreferences.getInstance(), tokenStorage: storage);

  await tester.pumpWidget(
    App(
      router: createRouter(session: sl(), prefs: sl()),
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

const _returning = {'launched_before': true, 'onboarding_seen': true};

void main() {
  tearDown(sl.reset);

  testWidgets('first launch: onboarding → phone → code → profile → home', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.byType(OnboardingPage), findsOneWidget);

    await _tap(tester, 'Пропустити');
    expect(find.text('Вхід: номер телефону'), findsOneWidget);

    await _tap(tester, 'Отримати код');
    expect(find.text('Вхід: код із SMS'), findsOneWidget);

    await _tap(tester, 'Увійти як новий користувач');
    expect(find.text('Реєстрація: профіль'), findsOneWidget);

    await _tap(tester, 'Зберегти');
    expect(find.text('Головна'), findsWidgets);
    expect(find.text('Заглушка'), findsOneWidget);
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

  testWidgets('existing user skips the profile step', (tester) async {
    await _pumpApp(tester, prefs: _returning);
    expect(find.text('Вхід: номер телефону'), findsOneWidget);

    await _tap(tester, 'Отримати код');
    await _tap(tester, 'Увійти як існуючий користувач');

    expect(find.text('Реєстрація: профіль'), findsNothing);
    expect(find.text('Головна'), findsWidgets);
  });

  testWidgets('back from the code screen returns to the phone screen', (
    tester,
  ) async {
    await _pumpApp(tester, prefs: _returning);
    await _tap(tester, 'Отримати код');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Вхід: номер телефону'), findsOneWidget);
  });

  testWidgets('stored session opens home right away', (tester) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    expect(find.text('Головна'), findsWidgets);
    expect(find.text('Вхід: номер телефону'), findsNothing);
  });

  testWidgets('unfinished profile reopens the profile step', (tester) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: true),
    );

    expect(find.text('Реєстрація: профіль'), findsOneWidget);
  });

  testWidgets('tabs switch and sign-out returns to the phone screen', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    await _tap(tester, 'Профіль');
    expect(find.text('Вийти'), findsOneWidget);

    await _tap(tester, 'Вийти');
    expect(find.text('Вхід: номер телефону'), findsOneWidget);
    expect(await sl<TokenStorage>().read(), isNull);
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
