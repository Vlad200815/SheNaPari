import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../gen/assets.gen.dart';
import '../../gen/colors.gen.dart';
import 'routes.dart';

/// The tab bar around the main screens. Each tab keeps its own stack.
///
/// Two tabs on each side and a raised round button in the middle that opens
/// the QR of the active order: the customer shows it at pickup.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Same order as the shell branches in `app_router.dart`.
  static final _tabs = [
    _Tab(Assets.images.bottomNav.icHome, 'Головна'),
    _Tab(Assets.images.bottomNav.icCart, 'Кошик'),
    _Tab(Assets.images.bottomNav.icOrders, 'Замовлення'),
    _Tab(Assets.images.bottomNav.icProfile, 'Профіль'),
  ];

  void _openTab(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab again returns to its first screen.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    Widget tab(int index) => Expanded(
      child: _TabButton(
        tab: _tabs[index],
        selected: index == navigationShell.currentIndex,
        onTap: () => _openTab(index),
      ),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorName.white,
          boxShadow: [
            BoxShadow(
              color: ColorName.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        // Keeps the buttons above the iPhone home indicator.
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                tab(0),
                tab(1),
                const SizedBox(width: 96, child: _QrButtonSlot()),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.icon, this.label);

  final SvgGenImage icon;
  final String label;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorName.primary400 : ColorName.secondary500;
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: tab.icon.svg(
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
              child: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Holds the round button, which sticks out above the bar.
class _QrButtonSlot extends StatelessWidget {
  const _QrButtonSlot();

  static const _size = 84.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -30,
          child: Semantics(
            button: true,
            label: 'Мій QR',
            child: Material(
              color: ColorName.primary400,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: ColorName.primary500.withValues(alpha: 0.45),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push(Routes.myQr),
                child: SizedBox.square(
                  dimension: _size,
                  child: Center(
                    // The icon itself is white.
                    child: Assets.images.icScan.svg(width: 34, height: 34),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
