import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/choice_menu_row.dart';
import '../../../../core/ui/app_colors.dart';

/// How a language is named in the list: each in its own language, so it is
/// found even by someone who cannot read the current one.
String languageName(AppLanguage language) => switch (language) {
  AppLanguage.system => LocaleKeys.settings_language_system.tr(),
  AppLanguage.uk => 'Українська',
  AppLanguage.en => 'English',
};

/// «Мова» in the settings: the current flag, a drop-down with the three
/// choices.
class LanguageRow extends StatelessWidget {
  const LanguageRow({super.key, required this.current, required this.onPicked});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onPicked;

  @override
  Widget build(BuildContext context) => ChoiceMenuRow<AppLanguage>(
    icon: Icons.translate_rounded,
    tint: ColorName.green,
    title: LocaleKeys.settings_language.tr(),
    values: AppLanguage.values,
    current: current,
    nameOf: languageName,
    badge: (language, size) => LanguageBadge(language, size: size),
    onPicked: onPicked,
  );
}

/// A flag as a small rounded rectangle (3:2, like a real one), or, for
/// «Як у системі», a phone in a circle. Both take the same [size] square, so
/// the names next to them line up. Decorative: the name is always beside it.
class LanguageBadge extends StatelessWidget {
  const LanguageBadge(this.language, {super.key, required this.size});

  final AppLanguage language;
  final double size;

  @override
  Widget build(BuildContext context) {
    final flag = switch (language) {
      AppLanguage.uk => Assets.images.flags.ua,
      AppLanguage.en => Assets.images.flags.us,
      AppLanguage.system => null,
    };
    // A hairline so the flags' white parts do not melt into the menu.
    final hairline = Border.all(color: context.colors.hairline);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: flag == null
              ? CircleBadge(Icons.smartphone_rounded, size: size)
              : Container(
                  width: size,
                  height: size * 2 / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.14),
                    border: hairline,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: flag.svg(
                    fit: BoxFit.cover,
                    // The US flag is longer than 3:2: trim its right end,
                    // so all the stars in the top-left corner stay.
                    alignment: Alignment.centerLeft,
                  ),
                ),
        ),
      ),
    );
  }
}
