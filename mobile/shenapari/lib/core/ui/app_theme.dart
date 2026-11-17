import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import 'app_text.dart';

/// Paddings and radii shared by all screens.
abstract final class AppDimens {
  static const horizontalPadding = 20.0;
  static const radius = 12.0;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorName.primary400,
    primary: ColorName.primary400,
    error: ColorName.red,
    surface: ColorName.white,
    secondary: ColorName.secondary500,
  ),
  scaffoldBackgroundColor: ColorName.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorName.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    displayLarge: AppText.heading(),
    bodyLarge: AppText.regular(),
    bodyMedium: AppText.regular(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius),
      borderSide: const BorderSide(color: ColorName.secondary200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius),
      borderSide: const BorderSide(color: ColorName.secondary200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius),
      borderSide: const BorderSide(color: ColorName.primary400),
    ),
  ),
);
