import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/core/ui/app_theme.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/features/menu/presentation/dish/widgets/nutrition_card.dart';
import 'package:shenapari/features/menu/presentation/widgets/dish_marks.dart';

Dish _dish({int spicy = 0, bool vegan = false}) => Dish(
  id: 1,
  categoryId: 1,
  name: 'Фалафель у піті',
  priceKopecks: 9500,
  weightG: 260,
  kcal: 480,
  proteinG: 16,
  fatG: 20,
  carbsG: 58,
  spicyLevel: spicy,
  isVegan: vegan,
);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: appTheme,
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('spicy and vegan say so in words', (tester) async {
    await _pump(tester, DishMarks(dish: _dish(spicy: 2, vegan: true)));

    expect(find.text('Гостре'), findsOneWidget);
    expect(find.text('Веганське'), findsOneWidget);
  });

  testWidgets('a plain dish has no marks at all', (tester) async {
    await _pump(tester, DishMarks(dish: _dish()));

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('on a card: icons only, the words for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, DishMarks(dish: _dish(spicy: 3), compact: true));

    expect(find.text('Дуже гостре'), findsNothing);
    expect(find.bySemanticsLabel('Дуже гостре'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('nutrition: calories, grams and the energy split', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, NutritionCard(dish: _dish()));

    expect(find.text('480'), findsOneWidget);
    expect(find.text('16 г'), findsOneWidget);
    expect(find.text('20 г'), findsOneWidget);
    expect(find.text('58 г'), findsOneWidget);
    // The bar is really drawn: three segments, 10 px high.
    final segments = tester.widgetList<ColoredBox>(
      find.descendant(
        of: find.byType(NutritionCard),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(segments, hasLength(3));
    for (final box
        in find
            .descendant(
              of: find.byType(NutritionCard),
              matching: find.byType(ColoredBox),
            )
            .evaluate()) {
      expect(box.size!.height, 10);
    }
    // 64 + 180 + 232 = 476 kcal.
    expect(
      find.bySemanticsLabel('Енергія: білки 13 %, жири 38 %, вуглеводи 49 %'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
