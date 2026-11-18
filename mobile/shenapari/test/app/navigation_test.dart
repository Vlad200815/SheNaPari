import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/app/app.dart';
import 'package:shenapari/app/bootstrap.dart';
import 'package:shenapari/app/di.dart';
import 'package:shenapari/app/router/app_router.dart';
import 'package:shenapari/app/splash_page.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/core/device/qr_display_mode.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/core/storage/token_storage.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/cart/presentation/cart_cubit.dart';
import 'package:shenapari/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:shenapari/features/auth/presentation/widgets/code_field.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/domain/order_events.dart';
import 'package:shenapari/features/orders/domain/orders_repository.dart';
import 'package:shenapari/features/notifications/domain/notifications_repository.dart';
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
late FakeOrdersRepository _orders;
late FakeOrderEvents _orderEvents;
late FakeNotificationsRepository _notifications;
late FakeQrDisplayMode _qrMode;

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
    ..registerSingleton<MenuRepository>(FakeMenuRepository())
    ..unregister<OrdersRepository>()
    ..registerSingleton<OrdersRepository>(_orders = FakeOrdersRepository())
    ..unregister<OrderEvents>()
    ..registerSingleton<OrderEvents>(_orderEvents = FakeOrderEvents())
    ..unregister<NotificationsRepository>()
    ..registerSingleton<NotificationsRepository>(
      _notifications = FakeNotificationsRepository(),
    )
    ..unregister<QrDisplayMode>()
    ..registerSingleton<QrDisplayMode>(_qrMode = FakeQrDisplayMode());

  // The QR button glows forever when an order is ready; with reduced motion
  // it stands still, so pumpAndSettle can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

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

/// «Більше» tab → «Мій профіль».
Future<void> _openMyProfile(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Більше'));
  await tester.pumpAndSettle();
  await _tap(tester, 'Мій профіль');
}

Future<void> _tap(WidgetTester tester, String label) async {
  // The test screen is short: scroll the target into view first.
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
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

    await _openMyProfile(tester);
    await _tap(tester, 'Вийти із застосунку');

    expect(find.text(_phoneTitle), findsOneWidget);
    expect(_auth.logoutCalls, 1);
    expect(await sl<TokenStorage>().read(), isNull);
  });

  testWidgets('menu → dish → cart, and sign-out empties the cart', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );

    // Buttons are found by their screen-reader labels.
    final semantics = tester.ensureSemantics();

    // Quick «+» on the card: one portion in the cart, the card keeps «+».
    final add = find.bySemanticsLabel('Додати Чізбургер в кошик');
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(sl<CartCubit>().state.count, 1);
    expect(add, findsOneWidget);

    // The dish screen starts from what is in the cart, not from 1 on top.
    await _tap(tester, 'Чізбургер');
    expect(find.text('Оновити · 85 ₴'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Більше'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Оновити · 170 ₴');
    expect(find.text('Кошик оновлено'), findsOneWidget);

    await tester.tap(find.byTooltip('Кошик'));
    await tester.pumpAndSettle();
    expect(find.text('170 ₴'), findsWidgets);
    expect(find.text('Разом · 2 порції'), findsOneWidget);
    // Let the «Кошик оновлено» snack bar go away before tapping below it.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await _openMyProfile(tester);
    await _tap(tester, 'Вийти із застосунку');
    expect(sl<CartCubit>().state.isEmpty, isTrue);
    semantics.dispose();
  });

  testWidgets('cart → checkout → paid: the cart is emptied', (tester) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );
    // The card is below the 600 px test screen: scroll to it first.
    await tester.ensureVisible(find.text('Чізбургер'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Чізбургер');
    await _tap(tester, 'Додати · 85 ₴');
    await tester.tap(find.byTooltip('Кошик'));
    await tester.pumpAndSettle();
    // Let the «Додано в кошик» snack bar go away: it covers the button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await _tap(tester, 'Оформити замовлення');
    // No breaks left today in the fake: «as soon as possible» is chosen.
    expect(find.text('Якнайшвидше'), findsOneWidget);
    await _tap(tester, 'Оплатити · 85 ₴');

    expect(find.text('Замовлення №7 оплачено'), findsOneWidget);
    expect(_orders.placed.single.breakSlotId, isNull);
    expect(_orders.placed.single.items.single.quantity, 1);
    expect(sl<CartCubit>().state.isEmpty, isTrue);

    await _tap(tester, 'Відстежити замовлення');
    expect(find.text('Замовлення №7'), findsOneWidget);
    expect(find.text('Готується'), findsOneWidget, reason: 'a step ahead');

    // The cook marks it ready; SignalR says so; the QR appears.
    _orders.kitchen('order-7', OrderStatus.ready, pickupToken: 'token-7');
    _orderEvents.changed('order-7');
    await tester.pumpAndSettle();
    expect(find.text('Скасувати замовлення'), findsNothing);

    // «Показати QR» opens the same sheet as the tab bar button.
    await _tap(tester, 'Показати QR');
    expect(find.text('Твій QR-код'), findsOneWidget);
    expect(find.text('Покажи код на видачі — і забирай'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Back lands on the orders tab, where it is listed as active.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Активні'), findsOneWidget);
    expect(find.text('Готово — забирай'), findsOneWidget);

    // «Мій QR»: a sheet over frosted glass with the ready order's code.
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel(RegExp('^Мій QR')));
    await tester.pumpAndSettle();
    expect(find.text('Твій QR-код'), findsOneWidget);
    expect(find.text('Покажи код на видачі — і забирай'), findsOneWidget);
    expect(find.bySemanticsLabel('QR-код замовлення №7'), findsOneWidget);

    // At the counter: brightness up, screen on, no screenshots.
    expect(_qrMode.on, isTrue);
    expect(find.bySemanticsLabel('Мій QR, готово: 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Твій QR-код'), findsNothing);
    expect(_qrMode.on, isFalse, reason: 'back to normal once closed');
    semantics.dispose();
  });

  testWidgets('bell: dot for unread, list, open the order, dot gone', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Сповіщення'), findsOneWidget);

    // The kitchen marks an order ready: a notification and a live event.
    await _orders.placeOrder(
      items: [
        CartItem(
          dish: (await FakeMenuRepository().getDish(10) as Ok<Dish>).value,
          quantity: 1,
        ),
      ],
      breakSlotId: null,
      provider: PaymentProvider.googlePay,
    );
    _notifications.add('Замовлення №7 готове!', orderId: 'order-7');
    _orderEvents.changed('order-7');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Сповіщення, є нові'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Сповіщення, є нові'));
    await tester.pumpAndSettle();
    expect(find.text('Замовлення №7 готове!'), findsOneWidget);
    expect(_notifications.markReadCalls, 1);

    await _tap(tester, 'Замовлення №7 готове!');
    expect(find.text('Замовлення №7'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Сповіщення'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('«Мій QR» with two ready orders: chips switch the QR', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );
    final dish = (await FakeMenuRepository().getDish(10) as Ok<Dish>).value;
    for (var i = 0; i < 2; i++) {
      await _orders.placeOrder(
        items: [CartItem(dish: dish, quantity: 1)],
        breakSlotId: null,
        provider: PaymentProvider.googlePay,
      );
    }
    _orders
      ..kitchen('order-7', OrderStatus.ready, pickupToken: 'token-7')
      ..kitchen('order-8', OrderStatus.ready, pickupToken: 'token-8');
    final semantics = tester.ensureSemantics();

    await tester.tap(find.bySemanticsLabel(RegExp('^Мій QR')));
    await tester.pumpAndSettle();
    expect(find.text('Твої QR-коди'), findsOneWidget);
    expect(find.text('№7 · Готово'), findsOneWidget);
    expect(find.text('№8 · Готово'), findsOneWidget);
    expect(find.bySemanticsLabel('QR-код замовлення №7'), findsOneWidget);

    await tester.tap(find.text('№8 · Готово'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('QR-код замовлення №8'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('«Більше» → «Мій профіль»: a new name shows in the header', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: _returning,
      stored: const StoredSession(tokens: _tokens, needsProfile: false),
    );
    _profile.savedName = 'Влад';

    await tester.tap(find.byTooltip('Більше'));
    await tester.pumpAndSettle();
    expect(find.text('Привіт, Влад!'), findsOneWidget);

    await _tap(tester, 'Мій профіль');
    await tester.enterText(find.byType(TextFormField).first, 'Владислав');
    await tester.pump();
    await _tap(tester, 'Зберегти');
    expect(find.text('Збережено'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Привіт, Владислав!'), findsOneWidget);
  });

  group('delete account', () {
    Future<void> openDeleteDialog(WidgetTester tester) async {
      await _pumpApp(
        tester,
        prefs: _returning,
        stored: const StoredSession(tokens: _tokens, needsProfile: false),
      );
      await _openMyProfile(tester);
      await _tap(tester, 'Налаштування');
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
