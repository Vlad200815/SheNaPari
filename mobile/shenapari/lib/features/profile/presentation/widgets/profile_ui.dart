import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/ui/app_colors.dart';

/// `+380681234567` → `+38 (068) 123-45-67`.
String formatProfilePhone(String phone) {
  final m = RegExp(r'^\+38(\d{3})(\d{3})(\d{2})(\d{2})$').firstMatch(phone);
  if (m == null) return phone;
  return '+38 (${m[1]}) ${m[2]}-${m[3]}-${m[4]}';
}

/// A white rounded card holding rows, with thin dividers between them.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 68, color: context.colors.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A row with a tinted icon tile, a title, an optional hint and a chevron.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.tint,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;

  /// Replaces the chevron, e.g. a flag and an arrow down for a drop-down.
  final Widget? trailing;

  /// The tile colour; the icon on it stays black for contrast.
  final Color tint;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: context.colors.textPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.medium().copyWith(
                        fontWeight: FontWeight.w500,
                        height: _titleHeight,
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
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.iconMuted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row with a switch; the whole row toggles it. [onChanged] null shows
/// it disabled (e.g. until the current value is loaded).
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.icon,
    required this.tint,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.medium().copyWith(
                          fontWeight: FontWeight.w500,
                          height: _titleHeight,
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
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: ColorName.white,
                  activeTrackColor: ColorName.primary400,
                  inactiveThumbColor: ColorName.white,
                  inactiveTrackColor: context.colors.disabled,
                  trackOutlineColor: const WidgetStatePropertyAll(
                    Colors.transparent,
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

/// Line height of a row title. The body style's 1.7 suits paragraphs; a
/// title that wraps to a second line (e.g. «Сповіщення про замовлення»)
/// needs its lines closer together.
const _titleHeight = 1.3;
