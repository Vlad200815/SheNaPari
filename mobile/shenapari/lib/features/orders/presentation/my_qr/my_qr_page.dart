import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../orders/orders_cubit.dart';
import '../widgets/order_texts.dart';
import '../widgets/order_widgets.dart';

/// «Мій QR»: a white sheet over the app, which stays visible on top behind
/// frosted yellow glass. Tapping the glass, swiping the sheet down or ✕
/// closes it. Opened with [myQrPage] (a see-through route).
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key});

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
              label: 'Закрити',
              child: GestureDetector(
                onTap: () => context.pop(),
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) {
                    final t = curved.value;
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16 * t, sigmaY: 16 * t),
                      child: ColoredBox(
                        color: ColorName.primary400.withValues(alpha: 0.35 * t),
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
                ? const _Sheet()
                : SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(curved),
                    child: const _Sheet(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The route for [MyQrPage]: not opaque, so the app shows through the glass.
/// Opens a little slower than it closes, which feels responsive.
Page<void> myQrPage(LocalKey key) => CustomTransitionPage(
  key: key,
  opaque: false,
  barrierColor: Colors.transparent,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  // MyQrPage animates itself (glass + sheet).
  transitionsBuilder: (_, _, _, child) => child,
  child: const MyQrPage(),
);

class _Sheet extends StatelessWidget {
  const _Sheet();

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
          color: ColorName.white,
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
                            child: Text(
                              'Твій QR-код',
                              style: AppText.heading().copyWith(fontSize: 26),
                            ),
                          ),
                          const _CloseButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: BlocBuilder<OrdersCubit, OrdersState>(
                          builder: (context, state) => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _content(context, state),
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
    final order = state.forPickup;
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
        text: state.failure!.message,
        button: 'Спробувати ще раз',
        onPressed: context.read<OrdersCubit>().load,
      ),
      OrdersStatus.loaded when order == null => _Message(
        key: const ValueKey('none'),
        icon: Icons.qr_code_2_rounded,
        text:
            'Немає активних замовлень. QR з’явиться тут, коли замовлення '
            'буде готове.',
        button: 'До меню',
        onPressed: () => context.go(Routes.home),
      ),
      OrdersStatus.loaded
          when order!.status == OrderStatus.ready &&
              order.pickupToken != null =>
        _ReadyQr(key: ValueKey('qr-${order.id}'), order: order),
      OrdersStatus.loaded => _NotReady(
        key: ValueKey('wait-${order!.id}'),
        order: order,
      ),
    };
  }
}

class _ReadyQr extends StatelessWidget {
  const _ReadyQr({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    // Big on a normal phone, smaller on a short screen so nothing overflows.
    final qrSize = (MediaQuery.sizeOf(context).height * 0.32).clamp(
      160.0,
      260.0,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            container: true,
            label: 'QR-код замовлення №${order.number}',
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
          Text('Замовлення №${order.number}', style: AppText.title()),
          Text('Покажи код на видачі — і забирай', style: AppText.small()),
          const SizedBox(height: 12),
          _DetailsLink(order: order),
        ],
      ),
    );
  }
}

class _NotReady extends StatelessWidget {
  const _NotReady({super.key, required this.order});

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
              color: ColorName.primary100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: ColorName.black),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'QR з’явиться тут, щойно кухня приготує '
                    'замовлення №${order.number} · ${order.whenLabel}',
                    style: AppText.small(color: ColorName.typography900),
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
        'Деталі замовлення',
        style: AppText.medium(
          color: ColorName.typography900,
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
            decoration: const BoxDecoration(
              color: ColorName.primary100,
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
          color: ColorName.secondary200,
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
      label: 'Закрити',
      excludeSemantics: true,
      child: Material(
        color: ColorName.secondary100,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.pop(),
          child: const SizedBox.square(
            dimension: 44,
            child: Icon(Icons.close_rounded, color: ColorName.black),
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
        color: ColorName.primary400.withValues(alpha: alpha),
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
