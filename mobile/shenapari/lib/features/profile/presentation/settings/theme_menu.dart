import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../widgets/choice_menu_row.dart';

String themeName(ThemeMode mode) => switch (mode) {
  ThemeMode.system => LocaleKeys.settings_theme_system.tr(),
  ThemeMode.light => LocaleKeys.settings_theme_light.tr(),
  ThemeMode.dark => LocaleKeys.settings_theme_dark.tr(),
};

/// «Тема» in the settings: as the phone, light or dark.
class ThemeRow extends StatelessWidget {
  const ThemeRow({super.key, required this.current, required this.onPicked});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onPicked;

  @override
  Widget build(BuildContext context) => ChoiceMenuRow<ThemeMode>(
    icon: Icons.contrast_rounded,
    tint: const Color(0xFF8E7CF0),
    title: LocaleKeys.settings_theme.tr(),
    values: ThemeMode.values,
    current: current,
    nameOf: themeName,
    badge: (mode, size) => CircleBadge(switch (mode) {
      ThemeMode.system => Icons.smartphone_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    }, size: size),
    onPicked: onPicked,
  );
}
