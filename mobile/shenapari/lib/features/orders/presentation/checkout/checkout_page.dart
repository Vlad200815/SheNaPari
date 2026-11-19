import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/paid_check.dart';
import '../../../../core/ui/app_logo.dart';
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
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

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
          backgroundColor: context.colors.background,
          appBar: state.status == CheckoutStatus.placed
              ? null
              : AppBar(
                  backgroundColor: context.colors.background,
                  title: Text(
                    LocaleKeys.checkout_title.tr(),
                    style: AppText.title(),
                  ),
                ),
          body: switch (state.status) {
            CheckoutStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            CheckoutStatus.loadFailure => _LoadError(
              message: state.failure!.text,
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
          _Notice(LocaleKeys.checkout_paused.tr()),
          const SizedBox(height: 16),
        ],
        _SectionTitle(LocaleKeys.checkout_when.tr()),
        for (final slot in state.breaks) ...[
          _Choice(
            icon: Icons.schedule_rounded,
            title: LocaleKeys.checkout_break_at.tr(
              namedArgs: {'time': formatClock(slot.startsAt)},
            ),
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
          title: LocaleKeys.checkout_asap.tr(),
          subtitle: state.breaks.isEmpty
              ? LocaleKeys.checkout_asap_no_breaks.tr()
              : LocaleKeys.checkout_asap_text.tr(),
          selected: state.breakSlotId == null,
          onTap: () => cubit.selectBreak(null),
        ),
        const SizedBox(height: 24),
        _SectionTitle(LocaleKeys.checkout_order.tr()),
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
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.dish.name,
                          style: AppText.small(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        formatPrice(item.totalKopecks),
                        style: AppText.small(color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(LocaleKeys.checkout_payment.tr()),
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
          LocaleKeys.checkout_payment_simulated.tr(),
          style: AppText.small(color: context.colors.textSecondary),
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
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
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
            text: LocaleKeys.checkout_pay.tr(
              namedArgs: {'total': formatPrice(cart.totalKopecks)},
            ),
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
            const Center(child: AppLogo()),
            // The check's box leaves room for the confetti, so no gap here.
            const Center(child: PaidCheck()),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.checkout_paid_title.tr(
                namedArgs: {'number': '${order.number}'},
              ),
              style: AppText.title().copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              slot == null
                  ? LocaleKeys.checkout_paid_asap.tr()
                  : LocaleKeys.checkout_paid_break.tr(
                      namedArgs: {'time': formatClock(slot.startsAt)},
                    ),
              style: AppText.regular(color: context.colors.textSecondary),
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
              text: LocaleKeys.checkout_track.tr(),
              onPressed: () => context.go(Routes.order(order.id)),
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              text: LocaleKeys.common_to_menu.tr(),
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
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? ColorName.primary400 : context.colors.surface,
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
                        : context.colors.fill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? ColorName.black
                        : context.colors.textPrimary,
                  ),
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
                        Text(
                          subtitle,
                          style: AppText.small(
                            color: context.colors.textSecondary,
                          ),
                        ),
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
                      : context.colors.disabled,
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
        color: context.colors.surface,
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
        color: context.colors.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_outline, color: ColorName.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppText.small(color: context.colors.textPrimary),
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
          Icon(Icons.cloud_off, size: 48, color: context.colors.iconMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppText.regular(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: LocaleKeys.common_retry.tr(),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
