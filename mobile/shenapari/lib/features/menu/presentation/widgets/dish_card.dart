import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/dish.dart';

/// A dish in the menu grid: photo, name, weight, price and a quick «+».
class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, this.onTap, this.onAdd});

  final Dish dish;

  /// Opens the dish details.
  final VoidCallback? onTap;

  /// Adds one portion to the cart.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorName.white,
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
                    if (dish.isPopular)
                      const Positioned(top: 6, left: 6, child: _PopularBadge()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dish.name,
                style: AppText.small(
                  color: ColorName.typography900,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text('${dish.weightG} г', style: AppText.small()),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatPrice(dish.priceKopecks),
                      style: AppText.title(),
                    ),
                  ),
                  if (onAdd != null) _AddButton(dish: dish, onTap: onAdd!),
                ],
              ),
            ],
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
                  const ColoredBox(color: ColorName.secondary50),
              errorWidget: (_, _, _) => const _NoImage(),
            ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: ColorName.secondary50,
      child: Center(
        child: Icon(Icons.restaurant, color: ColorName.secondary300, size: 36),
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
          'Хіт',
          style: AppText.small(
            color: ColorName.typography900,
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
      label: 'Додати ${dish.name} в кошик',
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
