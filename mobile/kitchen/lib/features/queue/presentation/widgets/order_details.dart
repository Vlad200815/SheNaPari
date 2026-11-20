import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/format_price.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/kitchen_order.dart';
import '../queue_cubit.dart';
import 'cancel_sheet.dart';
import 'order_ticket.dart';
import 'queue_colors.dart';

/// The order in full: what, who, how much, its history; «Скасувати» lives
/// here, not on the card, so a wet finger does not hit it by chance. A
/// centred panel on a tablet, a sheet on a phone.
Future<void> showOrderDetails(
  BuildContext context,
  KitchenOrder order, {
  required bool tablet,
}) {
  final cubit = context.read<QueueCubit>();
  final content = BlocProvider.value(
    value: cubit,
    child: _Details(order: order),
  );
  return tablet
      ? showDialog<void>(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: content,
            ),
          ),
        )
      : showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          builder: (_) => SafeArea(child: content),
        );
}

String _stepLabel(OrderStatus s) => switch (s) {
  OrderStatus.paid => LocaleKeys.order_steps_paid.tr(),
  OrderStatus.accepted => LocaleKeys.order_steps_accepted.tr(),
  OrderStatus.cooking => LocaleKeys.order_steps_cooking.tr(),
  OrderStatus.ready => LocaleKeys.order_steps_ready.tr(),
  OrderStatus.pickedUp => LocaleKeys.order_steps_picked_up.tr(),
  OrderStatus.cancelled => LocaleKeys.order_steps_cancelled.tr(),
  OrderStatus.notPickedUp => LocaleKeys.order_steps_not_picked_up.tr(),
  OrderStatus.unknown => '—',
};

class _Details extends StatelessWidget {
  const _Details({required this.order});

  final KitchenOrder order;

  @override
  Widget build(BuildContext context) {
    // Live: the same order as it is on the board now (or as last seen).
    final live = context.select<QueueCubit, KitchenOrder>(
      (c) => c.state.orders.firstWhere(
        (o) => o.id == order.id,
        orElse: () => order,
      ),
    );
    final colors = context.colors;
    final column = live.column;
    final name = live.customerName;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '№${live.number}',
                style: AppText.title().copyWith(fontSize: 26),
              ),
              const SizedBox(width: 10),
              if (column != null)
                Text(
                  columnStatusWord(column),
                  style: AppText.small(
                    color: ColumnLook.of(column).onTint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip: LocaleKeys.order_close.tr(),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          WhenChip(order: live),
          const SizedBox(height: 14),
          for (final item in live.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${item.quantity}×  ${item.name}',
                style: AppText.regular(color: colors.textPrimary),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (name != null && name.isNotEmpty)
                Text(
                  LocaleKeys.order_customer.tr(namedArgs: {'name': name}),
                  style: AppText.small(color: colors.textSecondary),
                ),
              const Spacer(),
              Text(
                '${LocaleKeys.order_total.tr()} ${formatPrice(live.totalKopecks)}',
                style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (live.history.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              LocaleKeys.order_history.tr(),
              style: AppText.small(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            for (final step in live.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 9,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.reason == null
                            ? _stepLabel(step.status)
                            : '${_stepLabel(step.status)} · ${step.reason}',
                        style: AppText.small(color: colors.textPrimary),
                      ),
                    ),
                    Text(
                      clock(step.at),
                      style: AppText.small(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
          if (live.canCancel) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final cubit = context.read<QueueCubit>();
                  final navigator = Navigator.of(context);
                  final reason = await showCancelSheet(context, live);
                  if (reason == null) return;
                  await cubit.cancel(live.id, reason: reason);
                  navigator.pop();
                },
                child: Text(
                  LocaleKeys.order_cancel.tr(),
                  style: AppText.button(color: colors.danger),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
