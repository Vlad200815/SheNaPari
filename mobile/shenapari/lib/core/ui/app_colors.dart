import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';

/// Colors by meaning, one set per theme: widgets ask for «the card colour»
/// or «secondary text», not for a hex value, so the dark theme only has to
/// be defined here.
///
/// Brand colours (yellow `primary400`, `red`, `green`, …) and dark text on
/// yellow stay `ColorName` constants: they are the same in both themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.fill,
    required this.surfaceMuted,
    required this.border,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.iconMuted,
    required this.disabled,
    required this.accentSoft,
    required this.accentDecor,
    required this.dangerSoft,
    required this.shadow,
    required this.decorOpacity,
  });

  /// Behind everything (scaffold, app bars).
  final Color background;

  /// Cards, sheets, dialogs, the tab bar.
  final Color surface;

  /// Small filled things on a card: circles, pills, the stepper.
  final Color fill;

  /// Image placeholders.
  final Color surfaceMuted;

  /// Outlines and dividers.
  final Color border;

  /// A barely visible edge, e.g. around a flag.
  final Color hairline;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Chevrons and other quiet icons.
  final Color iconMuted;

  /// Disabled controls, inactive dots, a switch that is off.
  final Color disabled;

  /// A soft brand tint behind text (hints, a new notification).
  final Color accentSoft;

  /// Decorative brand circles behind content (the dish header).
  final Color accentDecor;

  /// A soft red behind red text (errors, delete).
  final Color dangerSoft;

  /// Card shadows.
  final Color shadow;

  /// Multiplies the opacity of yellow decoration (circles, the tint behind
  /// the QR sheet): on a dark screen the same yellow looks twice as loud.
  final double decorOpacity;

  static const light = AppColors(
    background: ColorName.secondary100,
    surface: ColorName.white,
    fill: ColorName.secondary100,
    surfaceMuted: ColorName.secondary50,
    border: ColorName.secondary200,
    hairline: Color(0x14000000),
    textPrimary: ColorName.typography900,
    textSecondary: ColorName.typography500,
    textTertiary: ColorName.typography400,
    iconMuted: ColorName.secondary400,
    disabled: ColorName.secondary300,
    accentSoft: ColorName.primary100,
    accentDecor: Color(0x99FFE288),
    dangerSoft: ColorName.redLight,
    shadow: Color(0x0F000000),
    decorOpacity: 1,
  );

  /// Near-black like the reference screens; text contrast on [background]
  /// and [surface]: primary ≈17:1 / 15:1, secondary ≈7.6:1 / 6.6:1.
  static const dark = AppColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    fill: Color(0xFF2A2A2A),
    surfaceMuted: Color(0xFF262626),
    border: Color(0xFF353535),
    hairline: Color(0x29FFFFFF),
    textPrimary: Color(0xFFF4F4F5),
    textSecondary: Color(0xFFA3A3A8),
    textTertiary: Color(0xFF8A8A90),
    iconMuted: Color(0xFF8E8E93),
    disabled: Color(0xFF55565A),
    accentSoft: Color(0xFF3A3017),
    accentDecor: Color(0x1FFEBC2F),
    dangerSoft: Color(0xFF3B211C),
    shadow: Color(0x66000000),
    decorOpacity: 0.5,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : other ?? this;
}

extension AppColorsOf on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
