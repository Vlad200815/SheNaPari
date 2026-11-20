import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari/features/auth/presentation/widgets/phone_field.dart';

void main() {
  Future<List<String>> pump(WidgetTester tester, ThemeData theme) async {
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: PhoneField(onChanged: changes.add)),
      ),
    );
    return changes;
  }

  testWidgets('the clear button shows with text and empties the field', (
    tester,
  ) async {
    final changes = await pump(tester, appTheme);
    expect(find.byTooltip('Очистити'), findsNothing);

    await tester.enterText(find.byType(TextField), '671234567');
    await tester.pump();
    await tester.tap(find.byTooltip('Очистити'));
    await tester.pump();

    expect(changes.last, '');
    expect(find.byTooltip('Очистити'), findsNothing);
  });

  testWidgets('dark theme: the clear button is light', (tester) async {
    await pump(tester, appDarkTheme);
    await tester.enterText(find.byType(TextField), '67');
    await tester.pump();

    final circle = tester.widget<Container>(
      find.descendant(
        of: find.byTooltip('Очистити'),
        matching: find.byType(Container),
      ),
    );
    final color = (circle.decoration! as BoxDecoration).color!;
    // Close to the light text colour, far from the dark surface.
    expect(color.computeLuminance(), greaterThan(0.5));
    expect(AppColors.dark.surface.computeLuminance(), lessThan(0.05));
  });
}
