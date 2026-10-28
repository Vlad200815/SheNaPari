import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:shenapari/gen/assets.gen.dart";

class AppBarItem extends StatelessWidget implements PreferredSizeWidget {
  final bool hasLeading;
  final Widget? titleWidget;

  const AppBarItem({super.key, this.hasLeading = false, this.titleWidget});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: themeColors.surface,
      //TODO: change text style to the right one
      title: titleWidget,
      titleSpacing: 0,
      centerTitle: true,
      leading: hasLeading
          ? InkWell(
              onTap: () => context.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 44, // Large tap area
                height: 44,
                alignment: Alignment.center,
                child: Assets.images.icBackArrow.svg(
                  height: 16, // Small visual icon
                  width: 16,
                ),
              ),
            )
          : null,
      leadingWidth: hasLeading ? 56 : 0,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(36);
}
