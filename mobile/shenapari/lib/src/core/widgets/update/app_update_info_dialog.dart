import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';

import 'core/base_update_info_dialog.dart';

class NewVersionAlertDialog extends BaseUpdateInfoDialog {
  const NewVersionAlertDialog({
    super.onConfirm,
    super.onCancel,
    super.canDismiss = true,
  });

  @override
  Widget buildView(
    BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(Dimen.DEFAULT_HORIZONTAL_PADDING),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Assets.images.icForbes.svg(),
          const SizedBox(height: 36),
          Text(
            LocaleKeys.app_update_dialog_info_title.tr(),
            style: ThemeText.poppinsMedium(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.app_update_dialog_info_message.tr(),
            style: ThemeText.poppinsMedium(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Column(
            children: [
              // PrimaryButton(
              //   caption: LocaleKeys.app_update_dialog_btn_update.tr(),
              //   onPressed: onConfirm,
              // ),
              if (onCancel != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    LocaleKeys.app_update_dialog_btn_cancel.tr(),
                    style: ThemeText.poppinsMedium(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
