import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/snack_bars.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../menu/presentation/home/break_countdown.dart';
import '../../domain/entities/order.dart';
import 'rate_order_sheet.dart';
import 'rating_prompt_cubit.dart';
import 'rating_texts.dart';
import 'widgets/rating_stars.dart';

/// «Як вам №36?» under the break card, 30 min after pickup. A tap on a
/// star opens the sheet with that star already chosen, so the tap counts.
/// Nothing at all when there is nothing to ask.
class RatingPromptCard extends StatelessWidget {
  const RatingPromptCard({super.key});

  Future<void> _open(
    BuildContext context,
    RatingPrompt prompt,
    int stars,
  ) async {
    final cubit = context.read<RatingPromptCubit>();
    final rating = await showRateOrderSheet(
      context,
      orderId: prompt.orderId,
      number: prompt.number,
      subtitle: _subtitle(prompt),
      initialStars: stars,
    );
    if (rating == null || !context.mounted) return;
    cubit.rated(prompt.orderId);
    showInfoSnackBar(context, LocaleKeys.rating_sent.tr());
  }

  static String _subtitle(RatingPrompt prompt) =>
      '${itemsLine(prompt.items)} · ${formatClock(prompt.pickedUpAt)}';

  @override
  Widget build(BuildContext context) {
    final prompt = context.watch<RatingPromptCubit>().state;
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: prompt == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _Card(
                prompt: prompt,
                subtitle: _subtitle(prompt),
                onStar: (stars) => _open(context, prompt, stars),
                onDismiss: context.read<RatingPromptCubit>().dismiss,
              ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.prompt,
    required this.subtitle,
    required this.onStar,
    required this.onDismiss,
  });

  final RatingPrompt prompt;
  final String subtitle;
  final ValueChanged<int> onStar;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _DishBubbles(count: prompt.items.length),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.rating_ask.tr(
                        namedArgs: {'number': '${prompt.number}'},
                      ),
                      style: AppText.medium().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.rating_not_now.tr(),
                onPressed: onDismiss,
                style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
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
                  onChanged: onStar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One or two round dish placeholders, overlapping.
class _DishBubbles extends StatelessWidget {
  const _DishBubbles({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget bubble(IconData icon) => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.accentSoft,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 2),
      ),
      child: Icon(icon, size: 20, color: ratingAccent(context)),
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: count > 1 ? 58 : 40,
        height: 40,
        child: Stack(
          children: [
            bubble(Icons.lunch_dining_rounded),
            if (count > 1)
              Positioned(left: 18, child: bubble(Icons.local_cafe_rounded)),
          ],
        ),
      ),
    );
  }
}
