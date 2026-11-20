import 'package:material_ui/material_ui.dart';

import '../../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import '../../../domain/entities/dish.dart';

/// Calories big, then where they come from: one bar split by the energy of
/// protein, fat and carbs (4, 9 and 4 kcal per gram), and the grams under
/// it, each with its name in words — the colour is only a hint.
class NutritionCard extends StatelessWidget {
  const NutritionCard({super.key, required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final protein = dish.proteinG!, fat = dish.fatG!, carbs = dish.carbsG!;
    final parts = [
      (protein, protein * 4, colors.protein, LocaleKeys.dish_protein.tr()),
      (fat, fat * 9, ColorName.primary400, LocaleKeys.dish_fat.tr()),
      (carbs, carbs * 4, ColorName.primary500, LocaleKeys.dish_carbs.tr()),
    ];
    final total = parts.fold(0, (sum, p) => sum + p.$2);
    String percent(int kcal) => '${(kcal * 100 / total).round()}';
    final segments = [
      for (final (_, kcal, color, _) in parts)
        if (kcal > 0) (kcal, color),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${dish.kcal}',
                style: AppText.title().copyWith(
                  fontSize: 26,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                LocaleKeys.dish_kcal_per_portion.tr(),
                style: AppText.small(color: colors.textSecondary),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 10),
            Semantics(
              label: LocaleKeys.dish_energy_split.tr(
                namedArgs: {
                  'protein': percent(parts[0].$2),
                  'fat': percent(parts[1].$2),
                  'carbs': percent(parts[2].$2),
                },
              ),
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    // Without stretch an empty ColoredBox is 0 high.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, (kcal, color)) in segments.indexed) ...[
                        if (i > 0) const SizedBox(width: 2),
                        Expanded(
                          flex: kcal,
                          child: ColoredBox(color: color),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              for (final (grams, _, color, name) in parts)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.dish_grams.tr(
                          namedArgs: {'grams': '$grams'},
                        ),
                        style: AppText.medium().copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.small(color: colors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
