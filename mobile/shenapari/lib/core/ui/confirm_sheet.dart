import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_button.dart';
import 'app_colors.dart';
import 'app_text.dart';

/// «Are you sure?» before something that cannot be undone (cancel an order,
/// delete the account), as a sheet from the bottom like «Мій QR»: within
/// thumb reach, swiped down or tapped outside to back out.
///
/// The two buttons say what they do. The red one does the thing; the
/// outlined one under it keeps everything as it was. True only when the
/// red one was pressed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String text,
  required String confirm,
  required String keep,
}) async {
  HapticFeedback.mediumImpact();
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _ConfirmSheet(
      icon: icon,
      title: title,
      text: text,
      confirm: confirm,
      keep: keep,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.icon,
    required this.title,
    required this.text,
    required this.confirm,
    required this.keep,
  });

  final IconData icon;
  final String title;
  final String text;
  final String confirm;
  final String keep;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
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
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.dangerSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.danger, size: 34),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppText.title().copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: AppText.regular(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              AppButton.destructive(
                text: confirm,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
              AppButton.outlined(
                text: keep,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
