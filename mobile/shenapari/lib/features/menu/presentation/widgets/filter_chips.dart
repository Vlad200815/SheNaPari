import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/menu.dart';
import '../home/menu_filter.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// "Усі", "Популярне" (when there are popular dishes) and one chip per
/// category, scrolled horizontally.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.menu,
    required this.selected,
    required this.onSelected,
  });

  final Menu menu;
  final MenuFilter selected;
  final ValueChanged<MenuFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(MenuFilter, String)>[
      (const AllDishes(), LocaleKeys.home_filter_all.tr()),
      if (menu.hasPopular)
        (const PopularDishes(), LocaleKeys.home_filter_popular.tr()),
      for (final category in menu.categories)
        (CategoryDishes(category.id), category.name),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.horizontalPadding,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = filters[index];
          return _Chip(
            label: label,
            selected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorName.primary400 : context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(color: ColorName.primary400),
        ),
        child: Text(
          label,
          // White on primary400 is only 1.7:1, so the text stays dark.
          style: AppText.small(
            color: selected ? ColorName.black : context.colors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
