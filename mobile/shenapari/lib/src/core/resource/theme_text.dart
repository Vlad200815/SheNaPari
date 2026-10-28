import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shenapari/gen/colors.gen.dart';

typedef GoogleFontBuilder =
    TextStyle Function({
      TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? wordSpacing,
      TextBaseline? textBaseline,
      double? height,
      Locale? locale,
      Paint? foreground,
      Paint? background,
      List<ui.Shadow>? shadows,
      List<ui.FontFeature>? fontFeatures,
      TextDecoration? decoration,
      Color? decorationColor,
      TextDecorationStyle? decorationStyle,
      double? decorationThickness,
    });

/// FONT SIZES
const double HEADING_POPPINS_FONT_SIZE = 32.0;
// const double HEADING_ROBOTO_FONT_SIZE = 24.0;

const double MEDIUM_FONT_SIZE = 16.0;

// const double LARGE_FONT_SIZE = 17.0;
// const double MEDIUM_FONT_SIZE = 15.0;
// const double SMALL_FONT_SIZE = 12.0;

/// SPACING PERCENTAGES
const double SPACING_PERCENTAGE_MINUS_TWO = -0.02;
const double SPACING_PERCENTAGE_MINUS_HALF = -0.005;
const double SPACING_PERCENTAGE_DEFAULT = 0.0;

/// TEXT HEIGHTS
const double TEXT_HEIGHT_DEFAULT = 1.0;

class ThemeText {
  /// The Master Builder
  /// [fontStyle] takes a GoogleFont function like GoogleFonts.poppins
  static TextStyle _baseStyle({
    required GoogleFontBuilder fontFunction,
    required double fontSize,
    required FontWeight fontWeight,
    Color color = ColorName.typography900,
    required double spacingPercentage,
    required double height,
  }) {
    return fontFunction(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: fontSize * spacingPercentage,
      height: height,
    );
  }

  ///
  /// --- POPPINS ---
  ///

  /// poppinsHeading1
  static TextStyle poppinsHeading1({Color? color}) => _baseStyle(
    fontFunction: GoogleFonts.poppins,
    fontSize: HEADING_POPPINS_FONT_SIZE,
    fontWeight: FontWeight.w700,
    spacingPercentage: SPACING_PERCENTAGE_MINUS_TWO,
    height: 1.2,
    color: color ?? ColorName.typography900,
  );

  // /// poppinsHeading2
  // static TextStyle poppinsHeading2({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.poppins,
  //   fontSize: HEADING_POPPINS_FONT_SIZE,
  //   fontWeight: FontWeight.w700,
  //   spacingPercentage: SPACING_PERCENTAGE_MINUS_ONE,
  //   height: TEXT_HEIGHT_DEFAULT,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // /// poppinsHeadingLarge
  // static TextStyle poppinsHeadingLarge({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.poppins,
  //   fontSize: LARGE_FONT_SIZE,
  //   fontWeight: FontWeight.w700,
  //   spacingPercentage: SPACING_PERCENTAGE_MINUS_ONE,
  //   height: 1.5,
  //   color: color ?? ColorName.typography900,
  // );

  // /// poppinsHeadingMedium
  // static TextStyle poppinsHeadingMedium({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.poppins,
  //   fontSize: MEDIUM_FONT_SIZE,
  //   fontWeight: FontWeight.w400,
  //   spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
  //   height: 1.3,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // /// poppinsHeadingSmall
  // static TextStyle poppinsHeadingSmall({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.poppins,
  //   fontSize: SMALL_FONT_SIZE,
  //   fontWeight: FontWeight.w500,
  //   spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
  //   height: 1.3,
  //   color: color ?? ColorName.typography900,
  // );

  // /// poppinsBodyLarge
  // static TextStyle poppinsBodyLarge({
  //   required FontWeight fontWeight,
  //   Color? color,
  // }) {
  //   return _baseStyle(
  //     fontFunction: GoogleFonts.poppins,
  //     fontSize: LARGE_FONT_SIZE,
  //     fontWeight: fontWeight,
  //     spacingPercentage: SPACING_PERCENTAGE_MINUS_ONE,
  //     height: 1.5,
  //     color: color ?? ColorName.typography900,
  //   );
  // }

  /// poppinsMediumLarge
  static TextStyle poppinsMedium({FontWeight? fontWeight, Color? color}) {
    return _baseStyle(
      fontFunction: GoogleFonts.poppins,
      fontSize: MEDIUM_FONT_SIZE,
      fontWeight: fontWeight ?? FontWeight.w500,
      spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
      height: 1.7,
      color: color ?? ColorName.typography900,
    );
  }

  /// poppinsMediumSmall
  static TextStyle poppinsRegular({FontWeight? fontWeight, Color? color}) {
    return _baseStyle(
      fontFunction: GoogleFonts.poppins,
      fontSize: MEDIUM_FONT_SIZE,
      fontWeight: fontWeight ?? FontWeight.w400,
      spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
      height: 1.7,
      color: color ?? ColorName.typography900,
    );
  }

  /// poppinsButtonLarge
  static TextStyle poppinsButtonLarge({FontWeight? fontWeight, Color? color}) {
    return _baseStyle(
      fontFunction: GoogleFonts.poppins,
      fontSize: MEDIUM_FONT_SIZE,
      fontWeight: fontWeight ?? FontWeight.bold,
      spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
      height: 1.7,
      color: color ?? ColorName.typography900,
    );
  }

  ///
  /// --- ROBOTO ---
  ///

  /// robotoHeading
  // static TextStyle robotoHeading({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.roboto,
  //   fontSize: HEADING_ROBOTO_FONT_SIZE,
  //   fontWeight: FontWeight.w600,
  //   spacingPercentage: SPACING_PERCENTAGE_MINUS_TWO,
  //   height: TEXT_HEIGHT_DEFAULT,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // /// robotoBodyLarge
  // static TextStyle robotoBodyLarge({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.roboto,
  //   fontSize: LARGE_FONT_SIZE,
  //   fontWeight: FontWeight.w700,
  //   spacingPercentage: SPACING_PERCENTAGE_MINUS_ONE,
  //   height: 1.3,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // /// robotoBodyMedium
  // static TextStyle robotoBodyMedium({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.roboto,
  //   fontSize: MEDIUM_FONT_SIZE,
  //   fontWeight: FontWeight.w600,
  //   spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
  //   height: 1.3,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // /// robotoBodySmall
  // static TextStyle robotoBodySmall({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.roboto,
  //   fontSize: SMALL_FONT_SIZE,
  //   fontWeight: FontWeight.w600,
  //   spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
  //   height: 1.3,
  //   color: color ?? ColorName.typography900,
  // );
  //
  // ///
  // /// --- ROBOTO MONO ---
  // ///
  //
  // /// monoBodyMedium
  // static TextStyle monoBodyMedium({Color? color}) => _baseStyle(
  //   fontFunction: GoogleFonts.robotoMono,
  //   fontSize: MEDIUM_FONT_SIZE,
  //   fontWeight: FontWeight.w400,
  //   spacingPercentage: SPACING_PERCENTAGE_DEFAULT,
  //   height: 1.7,
  //   color: color ?? ColorName.typography900,
  // );

  static TextTheme buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? ColorName.typography900
        : ColorName.white;

    return TextTheme(
      /// --- DISPLAY (Large, Hero-style text) ---
      displayLarge: ThemeText.poppinsHeading1(color: color), // 32px Bold
      // displayMedium: ThemeText.poppinsHeading2(
      //   color: color,
      // ), // 32px Bold (different spacing)
      // displaySmall: ThemeText.robotoHeading(color: color), // 24px Semi-bold
      // /// --- HEADLINE (Major section titles) ---
      // headlineLarge: ThemeText.poppinsHeadingLarge(color: color), // 17px Bold
      // headlineMedium: ThemeText.poppinsHeadingMedium(
      //   color: color,
      // ), // 15px Regular
      // headlineSmall: ThemeText.poppinsHeadingSmall(color: color), // 12px Medium
      // /// --- TITLE (List items, card headers) ---
      // titleLarge: ThemeText.poppinsBodyLarge(
      //   fontWeight: FontWeight.w700,
      //   color: color,
      // ),
      // titleMedium: ThemeText.poppinsBodyLarge(
      //   fontWeight: FontWeight.w600,
      //   color: color,
      // ),
      // titleSmall: ThemeText.poppinsBodySmall(
      //   fontWeight: FontWeight.w600,
      //   color: color,
      // ),
      //
      // /// --- BODY (Standard reading text) ---
      // bodyLarge: ThemeText.robotoBodyLarge(color: color), // 17px Bold
      // bodyMedium: ThemeText.robotoBodyMedium(color: color), // 15px Semi-bold
      // bodySmall: ThemeText.robotoBodySmall(color: color), // 12px Semi-bold
      // /// --- LABEL (Buttons, captions, overline) ---
      // labelLarge: ThemeText.poppinsBodyLarge(
      //   fontWeight: FontWeight.w700,
      //   color: color,
      // ), // For Buttons
      // labelMedium: ThemeText.monoBodyMedium(
      //   color: color,
      // ), // For technical IDs/Prices
      // labelSmall: ThemeText.poppinsBodySmall(
      //   fontWeight: FontWeight.w400,
      //   color: color,
      // ),
    );
  }
}
