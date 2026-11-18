import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/device/qr_display_mode.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../orders/orders_cubit.dart';
import '../widgets/order_texts.dart';
import '../widgets/order_widgets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// «Мій QR»: a white sheet over the app, which stays visible on top behind
/// frosted yellow glass. Tapping the glass, swiping the sheet down or ✕
/// closes it. Opened with [myQrPage] (a see-through route).
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key, this.orderId});

  /// Open on this order (from its screen); otherwise the first ready one.
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final animation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: Stack(
        children: [
          // Frosted glass: blur says "the app is behind, tap to go back".
          Positioned.fill(
            child: Semantics(
              button: true,
              label: LocaleKeys.common_close.tr(),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) {
                    final t = curved.value;
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16 * t, sigmaY: 16 * t),
                      child: ColoredBox(
                        color: ColorName.primary400.withValues(
                          alpha: 0.35 * t * context.colors.decorOpacity,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: reduceMotion
                ? _Sheet(orderId: orderId)
                : SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(curved),
                    child: _Sheet(orderId: orderId),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The route for [MyQrPage]: not opaque, so the app shows through the glass.
/// Opens a little slower than it closes, which feels responsive.
Page<void> myQrPage(LocalKey key, {String? orderId}) => CustomTransitionPage(
  key: key,
  opaque: false,
  barrierColor: Colors.transparent,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  // MyQrPage animates itself (glass + sheet).
  transitionsBuilder: (_, _, _, child) => child,
  child: MyQrPage(orderId: orderId),
);

class _Sheet extends StatelessWidget {
  const _Sheet({required this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return GestureDetector(
      // Swipe down to dismiss, like any bottom sheet.
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) context.pop();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const _Decor(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Handle(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: BlocSelector<OrdersCubit, OrdersState, int>(
                              selector: (state) => state.readyCount,
                              builder: (context, ready) => Text(
                                ready > 1
                                    ? LocaleKeys.my_qr_title_many.tr()
                                    : LocaleKeys.my_qr_title_one.tr(),
                                style: AppText.heading().copyWith(fontSize: 26),
                              ),
                            ),
                          ),
                          const _CloseButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: BlocBuilder<OrdersCubit, OrdersState>(
                          builder: (context, state) => _QrDisplayScope(
                            // Brightness up, screen on, no screenshots —
                            // only while a ready code is actually shown.
                            active: state.readyCount > 0,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _content(context, state),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OrdersState state) {
    final orders = state.forPickup;
    return switch (state.status) {
      OrdersStatus.loading => const SizedBox(
        key: ValueKey('loading'),
        height: 280,
        child: Center(
          child: CircularProgressIndicator(color: ColorName.primary400),
        ),
      ),
      OrdersStatus.failure => _Message(
        key: const ValueKey('failure'),
        icon: Icons.cloud_off,
        text: state.failure!.text,
        button: LocaleKeys.common_retry.tr(),
        onPressed: context.read<OrdersCubit>().load,
      ),
      OrdersStatus.loaded when orders.isEmpty => _Message(
        key: const ValueKey('none'),
        icon: Icons.qr_code_2_rounded,
        text: LocaleKeys.my_qr_empty.tr(),
        button: LocaleKeys.common_to_menu.tr(),
        onPressed: () => context.go(Routes.home),
      ),
      OrdersStatus.loaded when orders.length == 1 => _OrderPage(
        key: ValueKey('one-${orders.single.id}-${orders.single.status}'),
        order: orders.single,
      ),
      // A stable key: live updates must not reset the chosen page.
      OrdersStatus.loaded => _OrderPager(
        key: const ValueKey('pager'),
        initialIndex: orderId == null
            ? 0
            : orders.indexWhere((o) => o.id == orderId).clamp(0, orders.length),
        orders: orders,
      ),
    };
  }
}

/// One order: its QR when ready, otherwise how far along it is.
class _OrderPage extends StatelessWidget {
  const _OrderPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return order.status == OrderStatus.ready && order.pickupToken != null
        ? _ReadyQr(order: order)
        : _NotReady(order: order);
  }
}

/// Several active orders: a row of chips («№2 · Готово», «№5 · Готується»)
/// and the matching cards, swipeable. The chips are the visible control,
/// so swiping is a shortcut, not the only way; each chip says the status
/// in words, not only by colour.
class _OrderPager extends StatefulWidget {
  const _OrderPager({super.key, required this.orders, this.initialIndex = 0});

  final int initialIndex;

  final List<Order> orders;

  @override
  State<_OrderPager> createState() => _OrderPagerState();
}

class _OrderPagerState extends State<_OrderPager> {
  late final _pages = PageController(initialPage: _index);
  late var _index = widget.initialIndex;

  @override
  void didUpdateWidget(_OrderPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A live update may remove an order (picked up): stay in range.
    if (_index >= widget.orders.length) _index = widget.orders.length - 1;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _open(int index) {
    setState(() => _index = index);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders;
    final pageHeight = _qrSize(context) + 150;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _OrderChip(
              order: orders[i],
              selected: i == _index,
              onTap: () => _open(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // As tall as one page needs, but never more than the sheet has
        // left on a short screen (the page content scrolls then).
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: pageHeight),
            child: PageView.builder(
              controller: _pages,
              itemCount: orders.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _OrderPage(order: orders[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  final Order order;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = order.status == OrderStatus.ready;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? ColorName.primary400 : context.colors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? ColorName.primary400 : context.colors.border,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ready ? Icons.qr_code_2_rounded : Icons.hourglass_top_rounded,
                  size: 18,
                  color: selected
                      ? ColorName.black
                      : context.colors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  LocaleKeys.my_qr_chip.tr(
                    namedArgs: {
                      'number': '${order.number}',
                      'status': ready
                          ? LocaleKeys.my_qr_ready.tr()
                          : order.statusLabel,
                    },
                  ),
                  style: AppText.small(
                    color: selected
                        ? ColorName.black
                        : context.colors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Big on a normal phone, smaller on a short screen so nothing overflows.
double _qrSize(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.32).clamp(160.0, 260.0);

class _ReadyQr extends StatelessWidget {
  const _ReadyQr({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final qrSize = _qrSize(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            container: true,
            label: LocaleKeys.my_qr_qr_label.tr(
              namedArgs: {'number': '${order.number}'},
            ),
            image: true,
            excludeSemantics: true,
            child: QrImageView(
              data: order.pickupToken!,
              size: qrSize,
              padding: EdgeInsets.zero,
              backgroundColor: ColorName.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: ColorName.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: ColorName.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleKeys.orders_number.tr(
              namedArgs: {'number': '${order.number}'},
            ),
            style: AppText.title(),
          ),
          Text(
            LocaleKeys.my_qr_show_hint.tr(),
            style: AppText.small(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 12),
          _DetailsLink(order: order),
        ],
      ),
    );
  }
}

class _NotReady extends StatelessWidget {
  const _NotReady({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: context.colors.textPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    LocaleKeys.my_qr_waiting.tr(
                      namedArgs: {
                        'number': '${order.number}',
                        'when': order.whenLabel,
                      },
                    ),
                    style: AppText.small(color: context.colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StatusSteps(order: order),
          const SizedBox(height: 8),
          Center(child: _DetailsLink(order: order)),
        ],
      ),
    );
  }
}

class _DetailsLink extends StatelessWidget {
  const _DetailsLink({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: () {
        context
          ..pop()
          ..push(Routes.order(order.id));
      },
      child: Text(
        LocaleKeys.my_qr_details.tr(),
        style: AppText.medium(
          color: context.colors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    super.key,
    required this.icon,
    required this.text,
    required this.button,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.colors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: ColorName.primary500),
          ),
        ),
        const SizedBox(height: 16),
        Text(text, style: AppText.regular(), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        AppButton.primary(text: button, onPressed: onPressed),
      ],
    );
  }
}

/// The grab handle at the top: shows the sheet can be swiped down.
class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: context.colors.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.common_close.tr(),
      excludeSemantics: true,
      child: Material(
        color: context.colors.fill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.pop(),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(Icons.close_rounded, color: context.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Soft yellow circles in the corners, where ToSim has its coins.
class _Decor extends StatelessWidget {
  const _Decor();

  @override
  Widget build(BuildContext context) {
    Widget bubble(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorName.primary400.withValues(
          alpha: alpha * context.colors.decorOpacity,
        ),
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(top: -60, right: -50, child: bubble(170, 0.18)),
            Positioned(top: 40, right: 30, child: bubble(26, 0.35)),
            Positioned(bottom: -70, left: -60, child: bubble(180, 0.14)),
            Positioned(bottom: 50, right: -30, child: bubble(90, 0.12)),
          ],
        ),
      ),
    );
  }
}

/// Turns [QrDisplayMode] on while [active] and off when it stops being
/// active or the sheet closes.
class _QrDisplayScope extends StatefulWidget {
  const _QrDisplayScope({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_QrDisplayScope> createState() => _QrDisplayScopeState();
}

class _QrDisplayScopeState extends State<_QrDisplayScope> {
  final _mode = sl<QrDisplayMode>();
  var _on = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_QrDisplayScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.active == _on) return;
    _on = widget.active;
    _on ? _mode.enter() : _mode.exit();
  }

  @override
  void dispose() {
    if (_on) _mode.exit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
