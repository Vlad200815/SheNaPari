import "package:flutter/material.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/resource/theme_text.dart";

class ButtonItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Decoration decoration;
  final TextStyle textStyle;
  final Color splashColor;
  final Color highlightColor;
  final double? horizontalPadding;

  // Private constructor
  const ButtonItem._({
    required this.text,
    required this.onTap,
    required this.decoration,
    required this.textStyle,
    required this.splashColor,
    required this.highlightColor,
    this.horizontalPadding,
  });

  /// Primary
  factory ButtonItem.primary({
    required String text,
    required VoidCallback onTap,
    double? horizontalPadding,
  }) {
    return ButtonItem._(
      horizontalPadding: horizontalPadding,
      text: text,
      onTap: onTap,
      splashColor: ColorName.orange,
      highlightColor: ColorName.primary500,
      textStyle: ThemeText.poppinsButtonLarge(color: ColorName.white),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColorName.primary400, ColorName.orange],
        ),
      ),
    );
  }

  ///Secondary
  factory ButtonItem.secondary({
    required String text,
    VoidCallback? onTap,
    double? horizontalPadding,
  }) {
    return ButtonItem._(
      text: text,
      onTap: () => onTap?.call(),
      horizontalPadding: horizontalPadding,
      decoration: BoxDecoration(
        color: ColorName.typography200,
        borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
      ),
      textStyle: ThemeText.poppinsButtonLarge(color: ColorName.typography500),
      splashColor: ColorName.typography100,
      highlightColor: ColorName.typography100,
    );
  }

  /// Outlined
  factory ButtonItem.outlined({
    required String text,
    required VoidCallback onTap,
    double? horizontalPadding,
  }) {
    return ButtonItem._(
      text: text,
      onTap: onTap,
      horizontalPadding: horizontalPadding,
      splashColor: ColorName.secondary200,
      highlightColor: ColorName.secondary100,
      textStyle: ThemeText.poppinsButtonLarge(color: ColorName.secondary500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
        border: Border.all(color: ColorName.secondary200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
        splashColor: splashColor,
        child: Ink(
          height: 52,
          decoration: decoration,
          child: Center(child: Text(text, style: textStyle)),
        ),
      ),
    );
  }
}
