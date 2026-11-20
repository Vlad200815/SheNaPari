import 'package:material_ui/material_ui.dart';

import '../../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/format_price.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/order_texts.dart';

/// A finished order in the history: an outcome mark, what was in it, the
/// number and time, the price. [first] / [last] round the corners, so the
/// rows of one month read as one card.
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.order,
    required this.onTap,
    this.first = false,
    this.last = false,
  });

  final Order order;
  final VoidCallback onTap;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const radius = Radius.circular(16);
    // Only what went wrong is spelled out; a green tick says «picked up».
    final (icon, tint, background, problem) = switch (order.status) {
      OrderStatus.cancelled => (
        Icons.close_rounded,
        colors.danger,
        colors.dangerSoft,
        true,
      ),
      OrderStatus.notPickedUp => (
        Icons.schedule_rounded,
        colors.warning,
        colors.warningSoft,
        true,
      ),
      _ => (Icons.check_rounded, colors.success, colors.successSoft, false),
    };
    final number = LocaleKeys.orders_number_short.tr(
      namedArgs: {'number': '${order.number}'},
    );

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.vertical(
        top: first ? radius : Radius.zero,
        bottom: last ? radius : Radius.zero,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: [
            LocaleKeys.orders_number.tr(
              namedArgs: {'number': '${order.number}'},
            ),
            order.statusLabel,
            order.itemsSummary,
            formatOrderDate(order.createdAt),
            formatPrice(order.totalKopecks),
          ].join(', '),
          excludeSemantics: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: first
                  ? null
                  : Border(top: BorderSide(color: colors.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: tint),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.itemsSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text:
                                '$number · ${formatOrderDate(order.createdAt)}',
                            children: [
                              if (problem)
                                TextSpan(
                                  text: ' · ${order.statusLabel}',
                                  style: TextStyle(
                                    color: tint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small(
                            color: colors.textSecondary,
                          ).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatPrice(order.totalKopecks),
                    style: AppText.medium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
