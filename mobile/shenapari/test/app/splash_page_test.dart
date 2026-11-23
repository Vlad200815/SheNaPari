import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/app/splash_page.dart';
import 'package:shenapari_core/ui/app_colors.dart';

Future<Color> _background(WidgetTester tester, Brightness system) async {
  tester.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  // The app's own theme may differ from the phone's: the splash follows the
  // phone, like the native splash before it.
  await tester.pumpWidget(
    MaterialApp(themeMode: ThemeMode.light, home: const SplashPage()),
  );
  return tester.widget<ColoredBox>(find.byKey(SplashPage.backgroundKey)).color;
}

void main() {
  testWidgets('light phone: the light app background', (tester) async {
    expect(
      await _background(tester, Brightness.light),
      AppColors.light.background,
    );
  });

  testWidgets('dark phone: the dark app background, no light flash', (
    tester,
  ) async {
    expect(
      await _background(tester, Brightness.dark),
      AppColors.dark.background,
    );
  });
}
