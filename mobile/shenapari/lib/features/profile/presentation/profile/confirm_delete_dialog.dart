import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/confirm_sheet.dart';

/// Asks "really delete?" and explains what happens. True only when the user
/// pressed «Так, видалити»; swiping the sheet away or «Залишити акаунт»
/// means no.
Future<bool> confirmDeleteAccount(BuildContext context) => showConfirmSheet(
  context,
  icon: Icons.delete_outline_rounded,
  title: LocaleKeys.profile_delete_title.tr(),
  text: LocaleKeys.profile_delete_text.tr(),
  confirm: LocaleKeys.profile_delete_confirm.tr(),
  keep: LocaleKeys.profile_delete_keep.tr(),
);
