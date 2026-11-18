import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import 'app_text.dart';
import '../../core/l10n/l10n.dart';

/// `−  2  +` in a rounded pill. A button turns grey at its limit.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Smaller buttons for list rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 40.0;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorName.secondary100,
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: LocaleKeys.common_less.tr(),
            size: size,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: compact ? 28 : 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: LocaleKeys.common_more.tr(),
            size: size,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled ? ColorName.white : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(
              icon,
              size: size * 0.5,
              color: enabled ? ColorName.typography900 : ColorName.secondary300,
            ),
          ),
        ),
      ),
    );
  }
}
