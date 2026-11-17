import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../orders/orders_cubit.dart';
import '../widgets/order_texts.dart';
import '../widgets/order_widgets.dart';

/// The round button in the middle of the tab bar: the QR to show at the
/// counter. Until the order is ready it shows how far along it is.
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: Scaffold(
        backgroundColor: ColorName.secondary100,
        appBar: AppBar(
          backgroundColor: ColorName.secondary100,
          title: Text('Мій QR', style: AppText.title()),
          leading: CloseButton(onPressed: () => context.pop()),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            final order = state.forPickup;
            return switch (state.status) {
              OrdersStatus.loading => const Center(
                child: CircularProgressIndicator(color: ColorName.primary400),
              ),
              OrdersStatus.failure => _Centered(
                icon: Icons.cloud_off,
                title: state.failure!.message,
                button: 'Спробувати ще раз',
                onPressed: context.read<OrdersCubit>().load,
              ),
              OrdersStatus.loaded when order == null => _Centered(
                icon: Icons.qr_code_2_rounded,
                title: 'Немає активних замовлень',
                subtitle: 'QR з’явиться тут, коли замовлення буде готове',
                button: 'До меню',
                onPressed: () => context.go(Routes.home),
              ),
              OrdersStatus.loaded => _ForOrder(order: order!),
            };
          },
        ),
      ),
    );
  }
}

class _ForOrder extends StatelessWidget {
  const _ForOrder({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final ready =
        order.status == OrderStatus.ready && order.pickupToken != null;
    return ListView(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      children: [
        if (ready) ...[
          Center(child: PickupQr(order: order, size: 240)),
          const SizedBox(height: 16),
          Text(
            'Замовлення готове — підійди до видачі',
            style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorName.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Замовлення №${order.number} ще не готове',
                  style: AppText.title().copyWith(fontSize: 20),
                ),
                Text(
                  'QR з’явиться тут, щойно кухня його приготує · '
                  '${order.whenLabel}',
                  style: AppText.small(),
                ),
                const SizedBox(height: 16),
                StatusSteps(order: order),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        AppButton.outlined(
          text: 'Деталі замовлення',
          onPressed: () => context.push(Routes.order(order.id)),
        ),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.title,
    required this.button,
    required this.onPressed,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 20),
          Text(title, style: AppText.title(), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: AppText.small(), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          AppButton.primary(text: button, onPressed: onPressed),
        ],
      ),
    );
  }
}
