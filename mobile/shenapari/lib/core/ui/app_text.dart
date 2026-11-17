import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';

/// Text styles from the design (Poppins).
abstract final class AppText {
  /// 32 px bold: screen titles.
  static TextStyle heading({Color color = ColorName.typography900}) =>
      GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 32 * -0.02,
        height: 1.2,
        color: color,
      );

  /// 16 px medium: input text, emphasised body.
  static TextStyle medium({Color color = ColorName.typography900}) =>
      _body(FontWeight.w500, color);

  /// 16 px regular: body text.
  static TextStyle regular({Color color = ColorName.typography900}) =>
      _body(FontWeight.w400, color);

  /// 16 px bold: button labels.
  static TextStyle button({Color color = ColorName.typography900}) =>
      _body(FontWeight.w700, color);

  static TextStyle _body(FontWeight weight, Color color) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: weight,
    height: 1.7,
    color: color,
  );
}
