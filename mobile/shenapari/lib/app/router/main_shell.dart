import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/ui/app_text.dart';
import '../../features/orders/presentation/orders/orders_cubit.dart';
import '../di.dart';
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
    _Tab(Assets.images.bottomNav.icMore, 'Більше'),
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

    // The customer's orders, live, for the glow on the QR button.
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: Scaffold(
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -24,
          child: BlocSelector<OrdersCubit, OrdersState, int>(
            selector: (state) => state.readyCount,
            builder: (context, ready) => _QrButton(ready: ready),
          ),
        ),
      ],
    );
  }
}

/// The «Мій QR» button. When an order is ready a light sweeps across it
/// diagonally from the top-left every few seconds and a count badge
/// appears, so the customer sees the code is waiting. Only this one element
/// moves; with reduced motion only the badge is shown.
class _QrButton extends StatefulWidget {
  const _QrButton({required this.ready});

  /// Orders ready for pickup.
  final int ready;

  @override
  State<_QrButton> createState() => _QrButtonState();
}

class _QrButtonState extends State<_QrButton>
    with SingleTickerProviderStateMixin {
  static const _size = 68.0;

  /// One sweep plus a pause; slow enough to never feel like flashing.
  late final _cycle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_QrButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final animate =
        widget.ready > 0 && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_cycle.isAnimating) {
      _cycle.repeat();
    } else if (!animate && _cycle.isAnimating) {
      _cycle
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready > 0;
    final animate = _cycle.isAnimating;
    return Semantics(
      button: true,
      label: ready ? 'Мій QR, готово: ${widget.ready}' : 'Мій QR',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: ColorName.primary400,
            shape: const CircleBorder(),
            elevation: 6,
            shadowColor: ColorName.primary500.withValues(alpha: 0.45),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push(Routes.myQr),
              child: SizedBox.square(
                dimension: _size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The icon itself is white.
                    Assets.images.icScan.svg(width: 28, height: 28),
                    if (animate)
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _cycle,
                          builder: (context, child) {
                            // Top-left → bottom-right during the first 45 %
                            // of the cycle, then out of sight.
                            final t = (_cycle.value / 0.45).clamp(0.0, 1.0);
                            final d = -_size + t * _size * 2;
                            return Transform.translate(
                              offset: Offset(d, d),
                              child: child,
                            );
                          },
                          child: Transform.rotate(
                            angle: 0.785398, // 45°, across the motion
                            child: Container(
                              width: 22,
                              height: _size * 1.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorName.white.withValues(alpha: 0),
                                    ColorName.white.withValues(alpha: 0.75),
                                    ColorName.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (ready)
            Positioned(top: -2, right: -2, child: _Badge(count: widget.ready)),
        ],
      ),
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
