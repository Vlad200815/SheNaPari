import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/kitchen_order.dart';
import 'queue_colors.dart';

/// One order on the board: a header with the number in its column's tint,
/// the «when» chips, what to cook and the one action of its column.
class OrderTicket extends StatefulWidget {
  const OrderTicket({
    super.key,
    required this.order,
    required this.now,
    required this.busy,
    required this.onAccept,
    required this.onReady,
    required this.onHandOver,
  });

  final KitchenOrder order;
  final DateTime now;
  final bool busy;
  final ValueChanged<int> onAccept;
  final VoidCallback onReady;
  final VoidCallback onHandOver;

  /// What the kitchen can promise (the server allows exactly these).
  static const etaOptions = [5, 10, 15, 20];

  /// A ready order waits this long before it shows red; the server closes
  /// it as «не забрано» at 30.
  static const waitingTooLong = Duration(minutes: 20);

  @override
  State<OrderTicket> createState() => _OrderTicketState();
}

class _OrderTicketState extends State<OrderTicket> {
  var _eta = 10;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final column = order.column ?? QueueColumn.fresh;
    final look = ColumnLook.of(column);
    final colors = context.colors;
    return Material(
      color: colors.fill,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: look.tint,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  '№${order.number}',
                  style: AppText.title().copyWith(fontSize: 21),
                ),
                const Spacer(),
                Icon(look.icon, size: 14, color: look.onTint),
                const SizedBox(width: 4),
                Text(
                  columnStatusWord(column),
                  style: AppText.small(
                    color: look.onTint,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _WhenChip(order: order),
                    ..._timing(order),
                  ],
                ),
                const SizedBox(height: 8),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${item.quantity}×  ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          TextSpan(text: item.name),
                        ],
                      ),
                      style: AppText.regular(color: colors.textPrimary),
                    ),
                  ),
                ..._actions(column),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// «щойно», «ще 7 хв», «+3 хв», «4 хв · Влад», «чекає 24 хв».
  List<Widget> _timing(KitchenOrder order) {
    int minutes(Duration d) => d.inSeconds <= 0 ? 0 : (d.inSeconds / 60).ceil();
    final now = widget.now;
    switch (order.column) {
      case QueueColumn.fresh:
        final ago = now.difference(order.createdAt).inMinutes;
        return [
          _CalmText(
            ago < 1
                ? LocaleKeys.queue_just_now.tr()
                : LocaleKeys.queue_min_ago.tr(namedArgs: {'n': '$ago'}),
          ),
        ];
      case QueueColumn.cooking:
        final eta = order.estimatedReadyAt;
        if (eta == null) return const [];
        return [
          if (now.isAfter(eta))
            _LateChip(
              LocaleKeys.queue_late.tr(
                namedArgs: {'n': '${minutes(now.difference(eta))}'},
              ),
            )
          else
            _CalmText(
              LocaleKeys.queue_left.tr(
                namedArgs: {'n': '${minutes(eta.difference(now))}'},
              ),
            ),
        ];
      case QueueColumn.ready:
        final since = order.readyAt;
        if (since == null) return const [];
        final waited = now.difference(since);
        final n = '${waited.inMinutes}';
        final name = order.customerName;
        return [
          if (waited >= OrderTicket.waitingTooLong)
            _LateChip(LocaleKeys.queue_waiting_long.tr(namedArgs: {'n': n}))
          else
            _CalmText(LocaleKeys.queue_ready_for.tr(namedArgs: {'n': n})),
          if (name != null && name.isNotEmpty) _CalmText('· $name'),
        ];
      case null:
        return const [];
    }
  }

  List<Widget> _actions(QueueColumn column) => switch (column) {
    QueueColumn.fresh => [
      const SizedBox(height: 10),
      Row(
        children: [
          for (final (i, m) in OrderTicket.etaOptions.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _EtaOption(
                minutes: m,
                selected: m == _eta,
                onTap: () => setState(() => _eta = m),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      _ActionButton(
        text: LocaleKeys.queue_accept.tr(namedArgs: {'n': '$_eta'}),
        color: ColorName.primary400,
        onColor: ColorName.black,
        busy: widget.busy,
        onTap: () => widget.onAccept(_eta),
      ),
    ],
    QueueColumn.cooking => [
      const SizedBox(height: 10),
      _ActionButton(
        text: LocaleKeys.queue_ready_btn.tr(),
        color: ColumnLook.of(QueueColumn.ready).band,
        onColor: ColumnLook.of(QueueColumn.ready).onBand,
        busy: widget.busy,
        onTap: widget.onReady,
      ),
    ],
    QueueColumn.ready => [
      const SizedBox(height: 10),
      _ActionButton(
        text: LocaleKeys.queue_hand_over.tr(),
        busy: widget.busy,
        onTap: widget.onHandOver,
      ),
    ],
  };
}

class _WhenChip extends StatelessWidget {
  const _WhenChip({required this.order});

  final KitchenOrder order;

  @override
  Widget build(BuildContext context) {
    final start = order.breakStartsAt;
    final asap = start == null;
    final fg = asap ? ColorName.black : context.colors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: asap ? ColorName.primary400 : context.colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            asap ? Icons.bolt_rounded : Icons.schedule_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            asap
                ? LocaleKeys.queue_asap.tr()
                : LocaleKeys.queue_break_at.tr(
                    namedArgs: {'time': clock(start)},
                  ),
            style: AppText.small(
              color: fg,
              fontWeight: FontWeight.w600,
            ).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LateChip extends StatelessWidget {
  const _LateChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ColumnLook.late.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_rounded, size: 14, color: ColumnLook.late),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppText.small(
            color: ColumnLook.late,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 12),
        ),
      ],
    ),
  );
}

class _CalmText extends StatelessWidget {
  const _CalmText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppText.small(
      color: context.colors.textSecondary,
    ).copyWith(fontSize: 12),
  );
}

class _EtaOption extends StatelessWidget {
  const _EtaOption({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? ColorName.primary400 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? ColorName.primary400 : context.colors.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                LocaleKeys.queue_eta.tr(namedArgs: {'n': '$minutes'}),
                style: AppText.small(
                  color: selected
                      ? ColorName.black
                      : context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width action, 52 high. Without [color] it is outlined.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.busy,
    required this.onTap,
    this.color,
    this.onColor,
  });

  final String text;
  final bool busy;
  final VoidCallback onTap;
  final Color? color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final outlined = color == null;
    final fg = onColor ?? context.colors.textPrimary;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: color ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: outlined
              ? BorderSide(color: context.colors.border)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: busy ? null : onTap,
          child: Center(
            child: busy
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  )
                : Text(text, style: AppText.button(color: fg)),
          ),
        ),
      ),
    );
  }
}
