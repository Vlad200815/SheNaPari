import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/features/menu/presentation/widgets/dish_card.dart';

Dish _dish(int id, String name) => Dish(
  id: id,
  categoryId: 1,
  name: name,
  priceKopecks: 6000,
  weightG: 190,
  kcal: 420,
);

void main() {
  testWidgets('a long name does not make the photo smaller', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final dish in [
                _dish(1, 'Чизбургер'),
                _dish(2, 'Французький хот-дог із дуже довгою назвою'),
              ])
                SizedBox(width: 170, height: 260, child: DishCard(dish: dish)),
            ],
          ),
        ),
      ),
    );

    final photos = tester.widgetList<DishImage>(find.byType(DishImage));
    final sizes = [for (final p in photos) tester.getSize(find.byWidget(p))];
    expect(sizes, hasLength(2));
    expect(sizes.first, sizes.last);
  });
}
