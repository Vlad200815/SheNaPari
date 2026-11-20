import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';

/// Page indicator: the selected dot is orange.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.selected});

  final int count;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i == selected
                  ? ColorName.primary400
                  : context.colors.disabled,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    );
  }
}
