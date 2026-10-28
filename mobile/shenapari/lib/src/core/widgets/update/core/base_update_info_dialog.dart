import 'package:flutter/material.dart';

import '../../../../../gen/colors.gen.dart';
import '../../../resource/theme_dimen.dart';

abstract class BaseUpdateInfoDialog {
  const BaseUpdateInfoDialog({
    required this.onConfirm,
    this.onCancel,
    this.canDismiss = true,
  });

  final VoidCallback? onConfirm;

  final VoidCallback? onCancel;

  final bool canDismiss;

  Widget buildView(
    BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  );

  Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: canDismiss,
      builder: (context) => PopScope(
        canPop: canDismiss,
        child: AlertDialog(
          content: buildView(
            context,
            onConfirm != null
                ? () {
                    onConfirm!();
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  }
                : null,
            onCancel != null
                ? () {
                    onCancel!();
                    if (context.mounted) {
                      Navigator.of(context).pop(false);
                    }
                  }
                : null,
          ),
          backgroundColor: ColorName.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Dimen.DEFAULT_HORIZONTAL_PADDING,
            ),
          ),
        ),
      ),
    );
  }
}
