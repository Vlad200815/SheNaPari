import 'dart:io';

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
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/cart_cubit.dart';
import '../../../menu/presentation/home/break_countdown.dart';
import '../../domain/entities/order.dart';
import 'checkout_cubit.dart';
import 'checkout_state.dart';

/// When to pick up, what is ordered, how to pay — then «Оплатити».
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>().state;
    return BlocProvider(
      create: (_) => sl<CheckoutCubit>(
        param1: cart.items,
        // The wallet the phone has; the other one stays selectable.
        param2: Platform.isIOS
            ? PaymentProvider.applePay
            : PaymentProvider.googlePay,
      )..load(),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.failure != current.failure,
        listener: (context, state) {
          if (state.status == CheckoutStatus.placed) {
            context.read<CartCubit>().clear();
          } else if (state.status == CheckoutStatus.ready &&
              state.failure != null) {
            showFailureSnackBar(context, state.failure!);
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: state.status == CheckoutStatus.placed
              ? null
              : AppBar(
                  backgroundColor: ColorName.secondary100,
                  title: Text('Оформлення', style: AppText.title()),
                ),
          body: switch (state.status) {
            CheckoutStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            CheckoutStatus.loadFailure => _LoadError(
              message: state.failure!.message,
              onRetry: context.read<CheckoutCubit>().load,
            ),
            CheckoutStatus.placed => _Placed(order: state.order!),
            CheckoutStatus.ready ||
            CheckoutStatus.placing => _Form(state: state, cart: cart),
          },
          bottomNavigationBar:
              state.status == CheckoutStatus.ready ||
                  state.status == CheckoutStatus.placing
              ? _PayBar(state: state, cart: cart)
              : null,
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, required this.cart});

  final CheckoutState state;
  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      children: [
        if (!state.isAcceptingOrders) ...[
          const _Notice(
            'Кухня тимчасово не приймає замовлення. Спробуйте трохи пізніше.',
          ),
          const SizedBox(height: 16),
        ],
        const _SectionTitle('Коли забрати'),
        for (final slot in state.breaks) ...[
          _Choice(
            icon: Icons.schedule_rounded,
            title: 'Перерва о ${formatClock(slot.startsAt)}',
            subtitle:
                '${BreakCountdown(slot, now).timeLeft} · '
                '${formatClock(slot.startsAt)}–${formatClock(slot.endsAt)}',
            selected: state.breakSlotId == slot.id,
            onTap: () => cubit.selectBreak(slot.id),
          ),
          const SizedBox(height: 10),
        ],
        _Choice(
          icon: Icons.bolt_rounded,
          title: 'Якнайшвидше',
          subtitle: state.breaks.isEmpty
              ? 'Сьогодні перерв більше немає — кухня приготує одразу'
              : 'Кухня приготує, щойно прийме замовлення',
          selected: state.breakSlotId == null,
          onTap: () => cubit.selectBreak(null),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Замовлення'),
        _Card(
          child: Column(
            children: [
              for (final item in cart.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
                          item.dish.name,
                          style: AppText.small(color: ColorName.typography900),
                        ),
                      ),
                      Text(
                        formatPrice(item.totalKopecks),
                        style: AppText.small(color: ColorName.typography900),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Оплата'),
        for (final provider in const [
          PaymentProvider.applePay,
          PaymentProvider.googlePay,
        ]) ...[
          _Choice(
            icon: provider == PaymentProvider.applePay
                ? Icons.apple
                : Icons.account_balance_wallet_outlined,
            title: provider == PaymentProvider.applePay
                ? 'Apple Pay'
                : 'Google Pay',
            selected: state.provider == provider,
            onTap: () => cubit.selectProvider(provider),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          'Оплата в цій версії імітується: гроші не списуються.',
          style: AppText.small(),
        ),
      ],
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar({required this.state, required this.cart});

  final CheckoutState state;
  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: ColorName.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.horizontalPadding,
            16,
            AppDimens.horizontalPadding,
            16,
          ),
          child: AppButton.primary(
            text: 'Оплатити · ${formatPrice(cart.totalKopecks)}',
            loading: state.status == CheckoutStatus.placing,
            onPressed: state.canPay ? context.read<CheckoutCubit>().pay : null,
          ),
        ),
      ),
    );
  }
}

/// «Замовлення №7 оплачено» after a successful payment.
class _Placed extends StatelessWidget {
  const _Placed({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final slot = order.breakSlot;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  color: ColorName.primary400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: ColorName.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Замовлення №${order.number} оплачено',
              style: AppText.title().copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              slot == null
                  ? 'Кухня візьме його в роботу найближчим часом. '
                        'Ми повідомимо, коли буде готово.'
                  : 'Забери його на перерві о ${formatClock(slot.startsAt)} '
                        'без черги. Ми повідомимо, коли буде готово.',
              style: AppText.regular(color: ColorName.typography500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              formatPrice(order.totalKopecks),
              style: AppText.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              text: 'Відстежити замовлення',
              onPressed: () => context.go(Routes.order(order.id)),
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              text: 'До меню',
              onPressed: () => context.go(Routes.home),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable card: an icon, a title, an optional hint and a radio mark.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: ColorName.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? ColorName.primary400 : ColorName.white,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? ColorName.primary400
                        : ColorName.secondary100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: ColorName.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.medium().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle, style: AppText.small()),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? ColorName.primary500
                      : ColorName.secondary300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorName.redLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_outline, color: ColorName.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppText.small(color: ColorName.typography900),
            ),
          ),
        ],
      ),
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
