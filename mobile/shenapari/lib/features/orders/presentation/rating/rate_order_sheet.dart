import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_button.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_logo.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../../app/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/order.dart';
import '../checkout/widgets/paid_check.dart';
import 'rate_order_cubit.dart';
import 'rate_order_state.dart';
import 'rating_texts.dart';
import 'widgets/rating_stars.dart';
import 'widgets/rive_rating_stars.dart';
import '../../../../core/device/success_sound.dart';

/// The rating sheet. [initialStars]: the star tapped on the card that
/// opened it; [existing]: changing a rating already given. Returns what the
/// server saved, or null when closed without sending.
Future<OrderRating?> showRateOrderSheet(
  BuildContext context, {
  required String orderId,
  required int number,
  required String subtitle,
  int initialStars = 0,
  OrderRating? existing,
}) => showModalBottomSheet<OrderRating>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  barrierColor: Colors.black.withValues(alpha: 0.45),
  builder: (_) => BlocProvider(
    create: (_) => sl<RateOrderCubit>(
      param1: orderId,
      param2: (initialStars: initialStars, existing: existing),
    ),
    child: _RateOrderSheet(number: number, subtitle: subtitle),
  ),
);

/// The arguments [RateOrderCubit] takes besides the order id.
typedef RateOrderArgs = ({int initialStars, OrderRating? existing});

class _RateOrderSheet extends StatefulWidget {
  const _RateOrderSheet({required this.number, required this.subtitle});

  final int number;
  final String subtitle;

  @override
  State<_RateOrderSheet> createState() => _RateOrderSheetState();
}

class _RateOrderSheetState extends State<_RateOrderSheet> {
  Timer? _close;

  /// «Дякуємо!» stays this long, then the sheet goes by itself.
  static const thanksFor = Duration(milliseconds: 2400);

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<RateOrderCubit, RateOrderState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == RateOrderStatus.sent) {
          _close = Timer(thanksFor, () {
            if (mounted) Navigator.of(context).pop(state.rating);
          });
        }
      },
      builder: (context, state) => Padding(
        // Over the keyboard while the comment is typed.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Material(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      child: state.status == RateOrderStatus.sent
                          ? _Thanks(key: const ValueKey('thanks'), state: state)
                          : _Form(
                              key: const ValueKey('form'),
                              state: state,
                              number: widget.number,
                              subtitle: widget.subtitle,
                            ),
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

class _Form extends StatelessWidget {
  const _Form({
    super.key,
    required this.state,
    required this.number,
    required this.subtitle,
  });

  final RateOrderState state;
  final int number;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RateOrderCubit>();
    final colors = context.colors;
    final positive = state.stars >= 4;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.rating_ask.tr(namedArgs: {'number': '$number'}),
                    style: AppText.title().copyWith(fontSize: 18),
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
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: colors.fill,
                minimumSize: const Size(44, 44),
              ),
              icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: RiveRatingStars(value: state.stars, onChanged: cubit.setStars),
        ),
        SizedBox(
          height: 26,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              starsLabel(state.stars),
              key: ValueKey(state.stars),
              textAlign: TextAlign.center,
              style: AppText.medium(color: ratingAccent(context)),
            ),
          ),
        ),
        if (state.stars > 0) ...[
          const SizedBox(height: 8),
          Text(
            positive
                ? LocaleKeys.rating_liked.tr()
                : LocaleKeys.rating_wrong.tr(),
            textAlign: TextAlign.center,
            style: AppText.small(color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, tag) in state.offered.indexed)
                _Appear(
                  // A new side of tags enters again, one by one.
                  key: ValueKey('${positive ? 'good' : 'bad'}-$tag'),
                  delay: Duration(milliseconds: 60 + i * 45),
                  child: _TagChip(
                    label: tagLabel(tag),
                    selected: state.tags.contains(tag),
                    onTap: () => cubit.toggleTag(tag),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.commentOpen)
            _Appear(
              delay: Duration.zero,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextFormField(
                  initialValue: state.comment,
                  onChanged: cubit.setComment,
                  autofocus: state.comment.isEmpty,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: RateOrderCubit.maxComment,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppText.regular(),
                  decoration: InputDecoration(
                    labelText: LocaleKeys.rating_comment_label.tr(),
                    hintText: positive
                        ? LocaleKeys.rating_comment_good.tr()
                        : LocaleKeys.rating_comment_bad.tr(),
                  ),
                ),
              ),
            )
          else
            _CommentInvite(positive: positive, onTap: cubit.openComment),
        ],
        // Here, not a snack bar: one would sit under the sheet's dimming.
        if (state.failure case final failure?) ...[
          const SizedBox(height: 8),
          Text(
            failure.text,
            textAlign: TextAlign.center,
            style: AppText.small(color: colors.danger),
          ),
        ],
        const SizedBox(height: 12),
        AppButton.primary(
          text: LocaleKeys.rating_send.tr(),
          loading: state.status == RateOrderStatus.sending,
          onPressed: state.stars == 0 ? null : cubit.send,
        ),
      ],
    );
  }
}

/// The same success as «Оплачено»: logo, the yellow tick with confetti.
class _Thanks extends StatelessWidget {
  const _Thanks({super.key, required this.state});

  final RateOrderState state;

  @override
  Widget build(BuildContext context) {
    final rating = state.rating;
    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(width: 56),
          PaidCheck(size: 88, onTicked: context.read<SuccessSound>().play),
          Text(
            LocaleKeys.rating_thanks.tr(),
            style: AppText.title().copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            state.stars >= 4
                ? LocaleKeys.rating_thanks_good.tr()
                : LocaleKeys.rating_thanks_bad.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular(color: context.colors.textSecondary),
          ),
          if (rating != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingStars(value: rating.stars, starSize: 16, spacing: 0),
                  if (rating.tags.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        rating.tags.map(tagLabel).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.small(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.accentSoft : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? ColorName.primary400 : colors.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: ratingAccent(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Text(
                  label,
                  style: AppText.small(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «Додати коментар» as a quiet field-to-be: the same rounded box the
/// comment will open in, a pen in a soft circle, a «+» at the end. Tapping
/// anywhere on it opens the real field.
class _CommentInvite extends StatelessWidget {
  const _CommentInvite({required this.positive, required this.onTap});

  final bool positive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: ratingAccent(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.rating_add_comment.tr(),
                      style: AppText.small(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      positive
                          ? LocaleKeys.rating_comment_good.tr()
                          : LocaleKeys.rating_comment_bad.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and rises in after [delay]; just there with «reduce motion».
class _Appear extends StatefulWidget {
  const _Appear({super.key, required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}
