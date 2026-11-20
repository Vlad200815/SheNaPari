import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/app/di.dart';
import 'package:kitchen/features/auth/domain/staff_auth_repository.dart';
import 'package:kitchen/features/auth/presentation/login/login_cubit.dart';
import 'package:kitchen/features/auth/presentation/login/login_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/session/session_repository.dart';
import 'package:shenapari_core/session/session_repository_impl.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';
import 'package:shenapari_core/ui/app_logo.dart';
import 'package:shenapari_core/ui/app_theme.dart';

import '../../../../fakes.dart';

void main() {
  setUp(() async {
    await sl.reset();
    final session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.restore();
    sl
      ..registerSingleton<SessionRepository>(session)
      ..registerSingleton<StaffAuthRepository>(FakeStaffAuthRepository())
      ..registerFactory(() => LoginCubit(sl(), sl()));
  });

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: appDarkTheme, home: const LoginPage()),
    );
  }

  testWidgets('phone: logo above the form; a wrong password under the field', (
    tester,
  ) async {
    await pump(tester, const Size(400, 860));
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Вхід для персоналу'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('email')),
      'cook@shenapari.local',
    );
    await tester.enterText(find.byKey(const ValueKey('password')), 'wrong');
    await tester.pump(); // the button turns on with both fields filled
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Невірний email або пароль'), findsOneWidget);
  });

  testWidgets('tablet: the brand on the left, «Кухня» under the logo', (
    tester,
  ) async {
    await pump(tester, const Size(1280, 800));

    expect(find.text('Кухня'), findsOneWidget);
    expect(find.text('Вхід для персоналу'), findsOneWidget);
  });
}
