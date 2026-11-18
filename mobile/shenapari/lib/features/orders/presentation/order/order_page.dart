import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../widgets/order_texts.dart';
import '../widgets/order_widgets.dart';
import 'order_cubit.dart';

/// One order: status steps (live), the QR once ready, what was ordered and
/// cancellation while the kitchen has not started cooking.
class OrderPage extends StatelessWidget {
  const OrderPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderCubit>(param1: orderId)..load(),
      child: BlocConsumer<OrderCubit, OrderState>(
        listenWhen: (previous, current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure!),
        builder: (context, state) => Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: AppBar(
            backgroundColor: ColorName.secondary100,
            leading: BackButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.orders),
            ),
            title: Text(
              state.order == null
                  ? 'Замовлення'
                  : 'Замовлення №${state.order!.number}',
              style: AppText.title(),
            ),
          ),
          body: switch (state.status) {
            OrderLoadStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            OrderLoadStatus.failure => _LoadError(
              message: state.failure!.message,
              onRetry: context.read<OrderCubit>().load,
            ),
            OrderLoadStatus.loaded => _OrderView(
              order: state.order!,
              cancelling: state.cancelling,
            ),
          },
        ),
      ),
    );
  }
}

class _OrderView extends StatelessWidget {
  const _OrderView({required this.order, required this.cancelling});

  final Order order;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderCubit>();
    final ended =
        order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.notPickedUp;
    return RefreshIndicator(
      color: ColorName.primary400,
      onRefresh: cubit.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.horizontalPadding),
        children: [
          _Card(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.statusLabel,
                        style: AppText.title().copyWith(fontSize: 22),
                      ),
                      Text(
                        ended ? _endedHint(order) : order.whenLabel,
                        style: AppText.small(),
                      ),
                    ],
                  ),
                ),
                StatusChip(order: order),
              ],
            ),
          ),
          // One QR look everywhere: the button opens the same sheet as the
          // tab bar's «Мій QR», already on this order.
          if (order.status == OrderStatus.ready &&
              order.pickupToken != null) ...[
            const SizedBox(height: 16),
            AppButton.primary(
              text: 'Показати QR',
              onPressed: () => context.push(Routes.myQrFor(order.id)),
            ),
          ],
          if (!ended) ...[
            const SizedBox(height: 16),
            _Card(child: StatusSteps(order: order)),
          ],
          const SizedBox(height: 16),
          _Card(
            child: Column(
              children: [
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          '${item.quantity} ×',
                          style: AppText.small(
                            color: ColorName.typography900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppText.small(
                              color: ColorName.typography900,
                            ),
                          ),
                        ),
                        Text(
                          formatPrice(item.unitPriceKopecks * item.quantity),
                          style: AppText.small(color: ColorName.typography900),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 20, color: ColorName.secondary200),
                Row(
                  children: [
                    Text('Разом', style: AppText.medium()),
                    const Spacer(),
                    Text(
                      formatPrice(order.totalKopecks),
                      style: AppText.title(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Оформлено ${formatOrderDate(order.createdAt)}',
                    style: AppText.small(),
                  ),
                ),
              ],
            ),
          ),
          if (order.canCancel) ...[
            const SizedBox(height: 24),
            AppButton.outlined(
              text: 'Скасувати замовлення',
              loading: cancelling,
              onPressed: () async {
                if (await _confirmCancel(context, order)) await cubit.cancel();
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Скасувати можна, доки кухня не почала готувати. '
              'Гроші буде повернуто.',
              style: AppText.small(),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static String _endedHint(Order order) {
    if (order.status == OrderStatus.notPickedUp) {
      return 'Замовлення не забрали протягом 30 хвилин після готовності';
    }
    final reason = order.history
        .where((c) => c.status == OrderStatus.cancelled)
        .lastOrNull
        ?.reason;
    return reason == null ? 'Гроші повернуто' : 'Причина: $reason';
  }
}

Future<bool> _confirmCancel(BuildContext context, Order order) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ColorName.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Скасувати замовлення №${order.number}?',
        style: AppText.title(),
      ),
      content: Text(
        'Кухня не готуватиме його, а гроші буде повернуто.',
        style: AppText.small(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Ні',
            style: AppText.medium(color: ColorName.typography500),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Скасувати',
            style: AppText.medium(
              color: ColorName.red,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: ColorName.secondary400),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppText.regular(color: ColorName.typography500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton.primary(text: 'Спробувати ще раз', onPressed: onRetry),
        ],
      ),
    );
  }
}
