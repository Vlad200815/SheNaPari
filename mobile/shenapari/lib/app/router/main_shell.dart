import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/ui/app_text.dart';
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
  static const _tabs = [
    _Tab(Icons.home_outlined, Icons.home_rounded, 'Головна'),
    _Tab(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Кошик'),
    _Tab(Icons.receipt_long_outlined, Icons.receipt_long, 'Замовлення'),
    _Tab(Icons.person_outline_rounded, Icons.person_rounded, 'Профіль'),
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
            height: 64,
            child: Row(
              children: [
                tab(0),
                tab(1),
                const SizedBox(width: 84, child: _QrButtonSlot()),
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
  const _Tab(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
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
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? tab.selectedIcon : tab.icon,
              size: 26,
              color: selected ? ColorName.primary500 : ColorName.typography500,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Yellow text on white is only 1.7:1, so the label of the
              // selected tab gets dark and bold instead.
              style: AppText.small(
                color: selected
                    ? ColorName.typography900
                    : ColorName.typography500,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ).copyWith(fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -26,
          child: Semantics(
            button: true,
            label: 'Мій QR',
            child: Material(
              color: ColorName.primary400,
              shape: const CircleBorder(
                side: BorderSide(color: ColorName.white, width: 4),
              ),
              elevation: 4,
              shadowColor: ColorName.primary500.withValues(alpha: 0.5),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push(Routes.myQr),
                child: SizedBox.square(
                  dimension: 72,
                  child: Center(
                    child: Assets.images.icScan.svg(
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        ColorName.typography900,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 6,
          child: Text(
            'Мій QR',
            style: AppText.small(
              color: ColorName.typography500,
            ).copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
