import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';

/// How a language is named in the list: each in its own language, so it is
/// found even by someone who cannot read the current one.
String languageName(AppLanguage language) => switch (language) {
  AppLanguage.system => LocaleKeys.settings_language_system.tr(),
  AppLanguage.uk => 'Українська',
  AppLanguage.en => 'English',
};

/// A bottom sheet with the three choices, the current one ticked. Returns
/// the picked one, or null if closed without picking.
Future<AppLanguage?> pickLanguage(
  BuildContext context, {
  required AppLanguage current,
}) => showModalBottomSheet<AppLanguage>(
  context: context,
  backgroundColor: ColorName.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              LocaleKeys.settings_language.tr(),
              style: AppText.title(),
            ),
          ),
          for (final language in AppLanguage.values)
            _Option(
              title: languageName(language),
              selected: language == current,
              onTap: () => Navigator.of(context).pop(language),
            ),
        ],
      ),
    ),
  ),
);

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppText.medium().copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_rounded, color: ColorName.primary500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
