import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import 'order_texts.dart';
import '../../../../core/l10n/l10n.dart';

/// The status in a rounded pill.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: order.statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.statusLabel,
        style: AppText.small(
          color: ColorName.black,
          fontWeight: FontWeight.w600,
        ).copyWith(fontSize: 13),
      ),
    );
  }
}

/// An order in the list: №, status, when, what, how much.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorName.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    LocaleKeys.orders_number.tr(
                      namedArgs: {'number': '${order.number}'},
                    ),
                    style: AppText.medium().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(order: order),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                order.itemsSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.small(color: ColorName.typography900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    order.isActive
                        ? Icons.schedule_rounded
                        : Icons.event_outlined,
                    size: 16,
                    color: ColorName.typography500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.isActive
                          ? order.whenLabel
                          : formatOrderDate(order.createdAt),
                      style: AppText.small(),
                    ),
                  ),
                  Text(
                    formatPrice(order.totalKopecks),
                    style: AppText.medium().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paid → Accepted → Cooking → Ready → PickedUp as a vertical timeline.
class StatusSteps extends StatelessWidget {
  const StatusSteps({super.key, required this.order});

  final Order order;

  static List<(OrderStatus, String, String)> get _steps => [
    (
      OrderStatus.paid,
      LocaleKeys.orders_steps_paid.tr(),
      LocaleKeys.orders_steps_paid_text.tr(),
    ),
    (
      OrderStatus.accepted,
      LocaleKeys.orders_steps_accepted.tr(),
      LocaleKeys.orders_steps_accepted_text.tr(),
    ),
    (
      OrderStatus.cooking,
      LocaleKeys.orders_steps_cooking.tr(),
      LocaleKeys.orders_steps_cooking_text.tr(),
    ),
    (
      OrderStatus.ready,
      LocaleKeys.orders_steps_ready.tr(),
      LocaleKeys.orders_steps_ready_text.tr(),
    ),
    (
      OrderStatus.pickedUp,
      LocaleKeys.orders_steps_picked_up.tr(),
      LocaleKeys.orders_steps_picked_up_text.tr(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps.indexWhere((step) => step.$1 == order.status);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _Step(
            title: _steps[i].$2,
            hint: _steps[i].$3,
            time: order.reachedAt(_steps[i].$1),
            done: i <= current,
            isCurrent: i == current,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.hint,
    required this.time,
    required this.done,
    required this.isCurrent,
    required this.isLast,
  });

  final String title;
  final String hint;
  final DateTime? time;
  final bool done;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final time = this.time;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? ColorName.primary400 : ColorName.white,
                    border: Border.all(
                      color: done
                          ? ColorName.primary400
                          : ColorName.secondary200,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: ColorName.black,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: done
                          ? ColorName.primary400
                          : ColorName.secondary200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              AppText.medium(
                                color: done
                                    ? ColorName.typography900
                                    : ColorName.typography400,
                              ).copyWith(
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                      if (time != null)
                        Text(
                          '${time.hour.toString().padLeft(2, '0')}:'
                          '${time.minute.toString().padLeft(2, '0')}',
                          style: AppText.small(),
                        ),
                    ],
                  ),
                  if (isCurrent) Text(hint, style: AppText.small()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
