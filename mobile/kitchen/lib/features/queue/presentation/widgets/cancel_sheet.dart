import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/format_price.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/kitchen_order.dart';

/// «Скасувати замовлення №38?» with a reason the customer will see. The
/// first reason is picked already, so it is two taps; «Інша причина…» opens
/// a field. Returns the reason, or null when the kitchen keeps the order.
Future<String?> showCancelSheet(BuildContext context, KitchenOrder order) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _CancelSheet(order: order),
  );
}

enum _Reason { outOfStock, overloaded, technical, other }

class _CancelSheet extends StatefulWidget {
  const _CancelSheet({required this.order});

  final KitchenOrder order;

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  var _reason = _Reason.outOfStock;
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  static String _label(_Reason reason) => switch (reason) {
    _Reason.outOfStock => LocaleKeys.cancel_reasons_out_of_stock.tr(),
    _Reason.overloaded => LocaleKeys.cancel_reasons_overloaded.tr(),
    _Reason.technical => LocaleKeys.cancel_reasons_technical.tr(),
    _Reason.other => LocaleKeys.cancel_reasons_something_else.tr(),
  };

  String? get _text => _reason == _Reason.other
      ? (_other.text.trim().isEmpty ? null : _other.text.trim())
      : _label(_reason);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      // Keeps the «other» field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Material(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
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
                    const SizedBox(height: 18),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.dangerSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: colors.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      LocaleKeys.cancel_title.tr(
                        namedArgs: {'number': '${widget.order.number}'},
                      ),
                      textAlign: TextAlign.center,
                      style: AppText.title().copyWith(fontSize: 21),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      LocaleKeys.cancel_text.tr(
                        namedArgs: {
                          'sum': formatPrice(widget.order.totalKopecks),
                        },
                      ),
                      textAlign: TextAlign.center,
                      style: AppText.small(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    for (final reason in _Reason.values) ...[
                      _ReasonTile(
                        label: _label(reason),
                        selected: reason == _reason,
                        onTap: () => setState(() => _reason = reason),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_reason == _Reason.other) ...[
                      TextField(
                        controller: _other,
                        autofocus: true,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        style: AppText.regular(),
                        decoration: InputDecoration(
                          hintText: LocaleKeys.cancel_other_hint.tr(),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            text: LocaleKeys.cancel_keep.tr(),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SheetButton(
                            text: LocaleKeys.cancel_confirm.tr(),
                            color: colors.danger,
                            onTap: _text == null
                                ? null
                                : () => Navigator.of(context).pop(_text),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
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
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? colors.danger : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppText.regular())),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? colors.danger : colors.iconMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.text, required this.onTap, this.color});

  final String text;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = color != null;
    final enabled = onTap != null;
    return SizedBox(
      height: 54,
      child: Material(
        color: filled ? (enabled ? color : colors.fill) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: filled ? BorderSide.none : BorderSide(color: colors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: AppText.button(
                color: filled
                    ? (enabled ? Colors.white : colors.textTertiary)
                    : colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
