import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import 'app_colors.dart';
import 'app_text.dart';

/// Paddings and radii shared by all screens.
abstract final class AppDimens {
  static const horizontalPadding = 20.0;
  static const radius = 12.0;

  /// How far the round «Мій QR» button sticks out above the tab bar. A bar
  /// at the bottom of a tab (the cart's «Оформити») keeps its buttons this
  /// much higher, so the round one never covers them.
  static const tabBarOverhang = 24.0;
}

final ThemeData appTheme = _theme(Brightness.light, AppColors.light);
final ThemeData appDarkTheme = _theme(Brightness.dark, AppColors.dark);

ThemeData _theme(Brightness brightness, AppColors c) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.radius),
    borderSide: BorderSide(color: color),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorName.primary400,
      brightness: brightness,
      primary: ColorName.primary400,
      onPrimary: ColorName.black,
      error: ColorName.red,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      secondary: ColorName.secondary500,
    ),
    extensions: [c],
    scaffoldBackgroundColor: c.background,
    canvasColor: c.surface,
    dividerColor: c.border,
    iconTheme: IconThemeData(color: c.textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
    ),
    // Text takes its colour from the theme: AppText styles have none by
    // default, so the same widget is dark on light and light on dark.
    textTheme: TextTheme(
      displayLarge: AppText.heading(color: c.textPrimary),
      titleMedium: AppText.medium(color: c.textPrimary),
      bodyLarge: AppText.regular(color: c.textPrimary),
      bodyMedium: AppText.regular(color: c.textPrimary),
      bodySmall: AppText.small(color: c.textSecondary),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ColorName.primary400,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: AppText.regular(color: c.textSecondary),
      floatingLabelStyle: AppText.regular(color: c.textSecondary),
      helperStyle: AppText.small(color: c.textSecondary),
      hintStyle: AppText.regular(color: c.textTertiary),
      border: border(c.border),
      enabledBorder: border(c.border),
      focusedBorder: border(ColorName.primary400),
    ),
  );
}
