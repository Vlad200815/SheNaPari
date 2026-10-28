import 'package:flutter/material.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';

const LIGHT_THEME = Brightness.light;
const DARK_THEME = Brightness.dark;

/// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: LIGHT_THEME,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: LIGHT_THEME,
    seedColor: ColorName.primary400,
    error: ColorName.red,
    surface: ColorName.white,
    secondary: ColorName.secondary500,
  ),

  textTheme: ThemeText.buildTextTheme(LIGHT_THEME),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: DARK_THEME,

  useMaterial3: true,
  //TODO: setup the correct dark theme colors
  colorScheme: ColorScheme.fromSeed(
    brightness: DARK_THEME,
    seedColor: ColorName.primary400,
    error: ColorName.red,
    surface: ColorName.white,
    secondary: ColorName.secondary500,
  ),

  textTheme: ThemeText.buildTextTheme(DARK_THEME),
);

// extensions: const [
//   SkeletonizerConfigData(
//     effect: ShimmerEffect(
//         baseColor: ColorName.white,
//         highlightColor: ColorName.white,
//         duration: Duration(seconds: 2)),
//     justifyMultiLineText: true,
//     ignoreContainers: false,
//   )
// ],
// primarySwatch: Colors.blue,
// scaffoldBackgroundColor: ColorName.white,
// appBarTheme: const AppBarTheme(
//   backgroundColor: ColorName.primary,
//   iconTheme: IconThemeData(color: ColorName.white),
// ),
// buttonTheme: const ButtonThemeData(
//   //TODO: here might be an error
//   buttonColor: ColorName.secondary,
//   disabledColor: ColorName.primary,
// ),

// final ShimmerEffect defaultSkeletonEffect = const ShimmerEffect(
//   baseColor: ColorName.white,
//   highlightColor: ColorName.white,
//   duration: Duration(seconds: 1),
// );
