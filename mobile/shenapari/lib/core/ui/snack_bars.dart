import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import '../result/failure.dart';

/// Shows the failure text from the server (already in Ukrainian).
void showFailureSnackBar(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: ColorName.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
