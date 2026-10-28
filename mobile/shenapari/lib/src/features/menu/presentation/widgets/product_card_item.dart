import "package:flutter/material.dart";
import "package:shenapari/gen/assets.gen.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/others/extension/extensions.dart";
import "package:shenapari/src/core/resource/theme_text.dart";
import "package:shenapari/src/features/menu/domain/entities/entities.dart";

import "../../../../core/widgets/widgets.dart";

class ProductCardItem extends StatelessWidget {
  final void Function() onTap;
  final ProductEntity? product;
  final String section;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.section,
  });

  bool get _isLoading => product == null;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? _SkeletonCard()
        : GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: ColorName.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Assets.images.home.star.svg(),
                      const SizedBox(width: 4),
                      //TODO: add the text style
                      Text("${product?.rating.orZero()}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Hero(
                      tag: "product-tag${product?.id}-$section",
                      child: Center(
                        child: ImageView(
                          url: (product?.image).orEmpty(),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (product?.title).orEmpty(),
                    //TODO: replace with the right style
                    style: ThemeText.poppinsRegular(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${product?.price.orZero()}"),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorName.primary400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: ImageView(
                            url: Assets.images.home.add.path,
                            iconColor: ColorName.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating placeholder
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: ColorName.secondary50,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),

          // Image placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorName.secondary50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title placeholder
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: ColorName.secondary50,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),

          // Price placeholder
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: ColorName.secondary50,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
