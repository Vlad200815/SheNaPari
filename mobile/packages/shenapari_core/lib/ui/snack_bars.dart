import 'package:material_ui/material_ui.dart';

import '../gen/colors.gen.dart';
import '../result/failure.dart';
import 'app_text.dart';
import '../l10n/l10n.dart';
import 'app_colors.dart';

/// Shows the failure text from the server (already in Ukrainian).
///
/// A soft card instead of a solid red bar: pale red background, thin red
/// border and an icon, so the error is clear without shouting. The text is
/// dark: red text on a pale background would fail the 4.5:1 contrast check.
void showFailureSnackBar(BuildContext context, Failure failure) => _show(
  context,
  _MessageCard(
    message: failure.text,
    icon: Icons.error_outline,
    accent: ColorName.red,
    background: context.colors.dangerSoft,
  ),
);

/// A neutral note in the same style, e.g. "copied to the clipboard".
void showInfoSnackBar(BuildContext context, String message) => _show(
  context,
  _MessageCard(
    message: message,
    icon: Icons.info_outline,
    accent: ColorName.primary500,
    background: context.colors.accentSoft,
  ),
);

void _show(BuildContext context, Widget card) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // The card draws everything; the bar itself stays invisible.
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        content: card,
      ),
    );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String message;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: ColorName.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppText.small(color: context.colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
