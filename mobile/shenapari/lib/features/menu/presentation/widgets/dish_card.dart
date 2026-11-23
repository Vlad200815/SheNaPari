import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari_core/ui/format_price.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import '../../domain/entities/dish.dart';
import 'dish_marks.dart';
import '../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/ui/app_colors.dart';

/// A dish in the menu grid: photo, name, weight, price and a quick «+».
/// A sold-out dish is grey with «Закінчилось» over the photo and no «+»;
/// it still opens, so its details stay readable.
class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, this.onTap, this.onAdd});

  final Dish dish;

  /// Opens the dish details.
  final VoidCallback? onTap;

  /// Adds one portion to the cart.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final soldOut = !dish.isAvailable;
    final card = Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DishImage(url: dish.imageUrl),
                    if (soldOut)
                      const Positioned(
                        left: 6,
                        bottom: 6,
                        child: SoldOutBadge(),
                      )
                    else if (dish.isPopular)
                      const Positioned(top: 6, left: 6, child: _PopularBadge()),
                    // Peppers / leaf as icons in the other corner.
                    Positioned(
                      top: 6,
                      right: 6,
                      child: DishMarks(dish: dish, compact: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _Name(dish.name),
              Text(
                LocaleKeys.home_weight.tr(
                  namedArgs: {'grams': '${dish.weightG}'},
                ),
                style: AppText.small(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatPrice(dish.priceKopecks),
                      style: AppText.title(),
                    ),
                  ),
                  if (onAdd != null && !soldOut)
                    _AddButton(dish: dish, onTap: onAdd!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!soldOut) return card;
    // Grey, not just paler: the photo loses its colour too.
    return Opacity(
      opacity: 0.6,
      child: ColorFiltered(colorFilter: greyscale, child: card),
    );
  }
}

/// The dish name, always two lines tall: the photo takes what is left of the
/// card, so a name that wraps must not make its photo smaller than the
/// neighbours'. An invisible two-line text sets the height, at any text size.
class _Name extends StatelessWidget {
  const _Name(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final style = AppText.small(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Stack(
      children: [
        ExcludeSemantics(
          child: Opacity(opacity: 0, child: Text('\n', style: style)),
        ),
        Text(
          name,
          style: style,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Turns any colours grey (luminance weights of sRGB).
const greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// «Закінчилось» on a dark chip, readable on any photo.
class SoldOutBadge extends StatelessWidget {
  const SoldOutBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorName.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          LocaleKeys.home_sold_out.tr(),
          style: AppText.small(
            color: ColorName.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A dish photo with a neutral stand-in while loading, on error or when the
/// dish has no photo at all.
class DishImage extends StatelessWidget {
  const DishImage({super.key, required this.url, this.radius = 8});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? const _NoImage()
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  ColoredBox(color: context.colors.surfaceMuted),
              errorWidget: (_, _, _) => const _NoImage(),
            ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: context.colors.iconMuted,
          size: 36,
        ),
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorName.primary400,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          LocaleKeys.home_hit.tr(),
          style: AppText.small(
            color: ColorName.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A yellow circle with «+»; the tab bar badge shows the count.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.dish, required this.onTap});

  final Dish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // container: its own node, not merged into the card's big tap target.
    return Semantics(
      container: true,
      button: true,
      label: LocaleKeys.home_add_to_cart.tr(namedArgs: {'name': dish.name}),
      excludeSemantics: true,
      child: Material(
        color: ColorName.primary400,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox.square(
            dimension: 36,
            child: Icon(Icons.add_rounded, color: ColorName.black, size: 22),
          ),
        ),
      ),
    );
  }
}
