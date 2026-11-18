import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';

/// Asks "really delete?" and explains what happens. True only when the user
/// pressed "Видалити"; tapping outside or "Скасувати" means no.
Future<bool> confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _ConfirmDeleteDialog(),
  );
  return confirmed ?? false;
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorName.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: ColorName.redLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: ColorName.red,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.profile_delete_title.tr(),
              style: AppText.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.profile_delete_text.tr(),
              style: AppText.small(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.destructive(
              text: LocaleKeys.profile_delete.tr(),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              text: LocaleKeys.common_cancel.tr(),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
