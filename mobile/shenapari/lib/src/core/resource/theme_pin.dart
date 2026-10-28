import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';

import 'theme_text.dart';

final defaultPinTheme = PinTheme(
  width: 64,
  height: 64,
  textStyle: ThemeText.poppinsMedium(),
  decoration: BoxDecoration(
    border: Border.all(
      color: ColorName.secondary200,
      width: Dimen.DEFAULT_BORDER_WIDTH,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(
    color: ColorName.primary400,
    width: Dimen.DEFAULT_BORDER_WIDTH,
  ),
  borderRadius: BorderRadius.circular(8),
);

// final submittedPinTheme = defaultPinTheme.copyWith(
//   decoration: defaultPinTheme.decoration?.copyWith(color: Colors.red),
// );
