import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari/features/menu/presentation/widgets/dish_card.dart';

void main() {
  testWidgets('a photo is decoded at the size it is shown, not 1024 px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Center(
          child: SizedBox.square(
            dimension: 150,
            child: DishImage(url: 'https://example.com/images/menu/a.jpg'),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.memCacheWidth, 450);
  });
}
