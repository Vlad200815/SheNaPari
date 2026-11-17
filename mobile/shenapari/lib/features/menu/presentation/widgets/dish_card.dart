import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/dish.dart';

/// A dish in the menu grid: photo, name, weight and price.
class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, this.onTap});

  final Dish dish;
  final VoidCallback? onTap;

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
              Text(formatPrice(dish.priceKopecks), style: AppText.title()),
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
  const DishImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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
