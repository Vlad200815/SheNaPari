import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/dish.dart';

/// «Гостре» with one to three peppers, and «Веганське» with a leaf: red and
/// green pills. Nothing for a dish that is neither: a «not spicy» mark on
/// every dish would only be noise.
///
/// [compact]: icons only, for the menu card's photo corner.
class DishMarks extends StatelessWidget {
  const DishMarks({super.key, required this.dish, this.compact = false});

  final Dish dish;
  final bool compact;

  static String spicyLabel(int level) => switch (level) {
    1 => LocaleKeys.dish_spicy_1.tr(),
    2 => LocaleKeys.dish_spicy_2.tr(),
    _ => LocaleKeys.dish_spicy_3.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final marks = [
      if (dish.spicyLevel > 0)
        _Mark(
          label: spicyLabel(dish.spicyLevel),
          compact: compact,
          color: colors.danger,
          background: colors.dangerSoft,
          icons: [
            for (var i = 0; i < dish.spicyLevel; i++)
              Assets.images.icChili.svg(
                width: compact ? 13 : 15,
                height: compact ? 13 : 15,
                colorFilter: ColorFilter.mode(colors.danger, BlendMode.srcIn),
              ),
          ],
        ),
      if (dish.isVegan)
        _Mark(
          label: LocaleKeys.dish_vegan.tr(),
          compact: compact,
          color: colors.success,
          background: colors.successSoft,
          icons: [
            Icon(
              Icons.eco_rounded,
              size: compact ? 14 : 16,
              color: colors.success,
            ),
          ],
        ),
    ];
    if (marks.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 6, children: marks);
  }
}

class _Mark extends StatelessWidget {
  const _Mark({
    required this.label,
    required this.compact,
    required this.color,
    required this.background,
    required this.icons,
  });

  final String label;
  final bool compact;
  final Color color;
  final Color background;
  final List<Widget> icons;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          // On a photo the pill sits on a solid surface, so it reads on any
          // picture; the tint goes behind the icons only.
          color: compact ? context.colors.surface : background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: compact
              ? [
                  BoxShadow(
                    color: context.colors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...icons,
            if (!compact) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: AppText.small(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
