import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../menu/presentation/home/break_countdown.dart';
import '../widgets/order_texts.dart';
import '../../domain/entities/order.dart';
import 'rate_order_sheet.dart';
import 'rating_texts.dart';
import 'widgets/rating_stars.dart';

/// On a picked-up order's page: «Як вам це замовлення?» with stars that open
/// the sheet, or the rating given, with «Змінити» while it still can be.
/// Nothing for other orders. [onRated] reloads the order.
class OrderRatingSection extends StatelessWidget {
  const OrderRatingSection({
    super.key,
    required this.order,
    required this.onRated,
  });

  final Order order;
  final VoidCallback onRated;

  Future<void> _open(BuildContext context, {int stars = 0}) async {
    final pickedUp = order.reachedAt(OrderStatus.pickedUp);
    final names = [for (final item in order.items) item.name];
    final rating = await showRateOrderSheet(
      context,
      orderId: order.id,
      number: order.number,
      subtitle: pickedUp == null
          ? itemsLine(names)
          : '${itemsLine(names)} · ${formatClock(pickedUp)}',
      initialStars: stars,
      existing: order.rating,
    );
    if (rating != null) onRated();
  }

  @override
  Widget build(BuildContext context) {
    final rating = order.rating;
    final until = order.rateUntil;
    if (rating == null && until == null) return const SizedBox.shrink();
    final colors = context.colors;
    final untilText = until == null
        ? null
        : (rating == null
                  ? LocaleKeys.rating_rate_until
                  : LocaleKeys.rating_change_until)
              .tr(namedArgs: {'date': formatOrderDate(until)});
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rating == null
            ? [
                Text(
                  LocaleKeys.rating_ask_this.tr(),
                  style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
                ),
                if (untilText != null)
                  Text(
                    untilText,
                    style: AppText.small(color: colors.textSecondary),
                  ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RatingStars(
                      value: 0,
                      starSize: 34,
                      spacing: 8,
                      onChanged: (stars) => _open(context, stars: stars),
                    ),
                  ),
                ),
              ]
            : [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.rating_yours.tr(),
                        style: AppText.medium().copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (until != null)
                      TextButton.icon(
                        onPressed: () => _open(context),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(44, 44),
                        ),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: ratingAccent(context),
                        ),
                        label: Text(
                          LocaleKeys.rating_change.tr(),
                          style: AppText.small(
                            color: ratingAccent(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: LocaleKeys.rating_star.tr(
                          namedArgs: {'n': '${rating.stars}'},
                        ),
                        child: ExcludeSemantics(
                          child: RatingStars(
                            value: rating.stars,
                            starSize: 22,
                            spacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        starsLabel(rating.stars),
                        style: AppText.medium(
                          color: ratingAccent(context),
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                if (rating.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in rating.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: ratingAccent(context),
                              ),
                              const SizedBox(width: 4),
                              Text(tagLabel(tag), style: AppText.small()),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                if (rating.comment case final comment?) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(comment, style: AppText.small()),
                  ),
                ],
                if (untilText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    untilText,
                    style: AppText.small(color: colors.textSecondary),
                  ),
                ],
              ],
      ),
    );
  }
}
