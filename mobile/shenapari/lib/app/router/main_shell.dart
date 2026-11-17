import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/ui/app_text.dart';
import '../../features/cart/domain/entities/cart.dart';
import '../../features/cart/presentation/cart_cubit.dart';
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
    Widget tab(int index, {int badge = 0}) => Expanded(
      child: _TabButton(
        tab: _tabs[index],
        selected: index == navigationShell.currentIndex,
        onTap: () => _openTab(index),
        badge: badge,
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
            height: 54,
            child: Row(
              children: [
                tab(0),
                BlocSelector<CartCubit, Cart, int>(
                  selector: (cart) => cart.count,
                  builder: (_, count) => tab(1, badge: count),
                ),
                const SizedBox(width: 80, child: _QrButtonSlot()),
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
    this.badge = 0,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  /// A count on the icon (portions in the cart); hidden when 0.
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorName.primary400 : ColorName.secondary500;
    // No caption on screen; screen readers and long-press still get the name.
    return Semantics(
      selected: selected,
      button: true,
      label: badge == 0 ? tab.label : '${tab.label}, $badge',
      excludeSemantics: true,
      child: Tooltip(
        message: tab.label,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.1 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  tab.icon.svg(
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: _Badge(count: badge),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Holds the round button, which sticks out above the bar.
class _QrButtonSlot extends StatelessWidget {
  const _QrButtonSlot();

  static const _size = 68.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -24,
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
                    child: Assets.images.icScan.svg(width: 28, height: 28),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorName.red,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: ColorName.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppText.small(
          color: ColorName.white,
          fontWeight: FontWeight.w700,
        ).copyWith(fontSize: 10, height: 1.1),
      ),
    );
  }
}
