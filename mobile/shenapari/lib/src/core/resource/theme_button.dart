import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';

///
/// All button styles are declared
///
class ThemeButton {
  static ButtonStyle getFilledButtonStyle({
    Color color = ColorName.primary400,
    bool isWrap = true,
    double height = 64,
  }) {
    return FilledButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.only(left: 36, right: 36),
      fixedSize: Size.fromHeight(height),
      minimumSize: isWrap ? null : const Size.fromHeight(0),
      backgroundColor: color,
      disabledBackgroundColor: ColorName.primary400,
      // textStyle: ThemeText.monoBodyMedium(),
    );
  }

  static ButtonStyle getLightFilledButtonStyle({
    Color color = ColorName.white,
    bool isWrap = true,
  }) {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.only(left: 36, right: 36),
      fixedSize: const Size.fromHeight(60),
      minimumSize: isWrap ? null : const Size.fromHeight(0),
      backgroundColor: color,
      disabledBackgroundColor: ColorName.white,
      // textStyle: ThemeText.monoBodyMedium(),
    );
  }
}
