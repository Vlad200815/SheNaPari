import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/profile_ui.dart';

/// How a language is named in the list: each in its own language, so it is
/// found even by someone who cannot read the current one.
String languageName(AppLanguage language) => switch (language) {
  AppLanguage.system => LocaleKeys.settings_language_system.tr(),
  AppLanguage.uk => 'Українська',
  AppLanguage.en => 'English',
};

/// «Мова» in the settings: the current flag and an arrow down; a tap drops
/// a menu right under the row with the three choices, the current one
/// ticked.
class LanguageRow extends StatefulWidget {
  const LanguageRow({super.key, required this.current, required this.onPicked});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onPicked;

  @override
  State<LanguageRow> createState() => _LanguageRowState();
}

class _LanguageRowState extends State<LanguageRow> {
  final _menu = MenuController();

  static const _menuWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _menu,
        // Right edge of the menu under the right edge of the row, where the
        // flag and the arrow are.
        alignmentOffset: Offset(constraints.maxWidth - _menuWidth - 12, 4),
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(ColorName.white),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(
            ColorName.black.withValues(alpha: 0.25),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        menuChildren: [
          for (final language in AppLanguage.values)
            _Option(
              language: language,
              selected: language == widget.current,
              width: _menuWidth - 12,
              onPressed: () => widget.onPicked(language),
            ),
        ],
        builder: (context, controller, _) => MenuRow(
          icon: Icons.translate_rounded,
          tint: ColorName.green,
          title: LocaleKeys.settings_language.tr(),
          subtitle: languageName(widget.current),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          trailing: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LanguageBadge(widget.current, size: 24),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: controller.isOpen ? 0.5 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: ColorName.secondary400,
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

class _Option extends StatelessWidget {
  const _Option({
    required this.language,
    required this.selected,
    required this.width,
    required this.onPressed,
  });

  final AppLanguage language;
  final bool selected;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: MenuItemButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(width, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStatePropertyAll(
            selected
                ? ColorName.primary400.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          overlayColor: WidgetStatePropertyAll(
            ColorName.primary400.withValues(alpha: 0.12),
          ),
        ),
        leadingIcon: LanguageBadge(language, size: 28),
        trailingIcon: selected
            ? const Icon(Icons.check_rounded, color: ColorName.black, size: 20)
            : null,
        child: Text(
          languageName(language),
          style: AppText.medium().copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
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
    final hairline = Border.all(color: ColorName.black.withValues(alpha: 0.08));
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: flag == null
              ? Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorName.secondary100,
                    border: hairline,
                  ),
                  child: Icon(
                    Icons.smartphone_rounded,
                    size: size * 0.6,
                    color: ColorName.typography900,
                  ),
                )
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
