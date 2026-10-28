import "package:flutter/material.dart";
import "package:shenapari/gen/assets.gen.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/resource/theme_text.dart";

import "../../../../app/config.dart";
import "../../../../core/widgets/widgets.dart";

class PhoneNumberInputItem extends StatelessWidget {
  final TextEditingController controller;
  final void Function()? onClear;
  final void Function(String) onChanged;

  const PhoneNumberInputItem({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [Config.PHONE_FORMATTER],
      onChanged: onChanged,
      cursorColor: ColorName.primary400,
      style: ThemeText.poppinsMedium(),
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageView(url: Assets.images.auth.icUA.path),

              const SizedBox(width: 12),

              Text(
                Config.BASE_UKRAINE_PHONE_NUMBER,
                style: ThemeText.poppinsMedium(),
              ),

              const SizedBox(width: 12),

              // Vertical divider line
              Container(height: 40, width: 1, color: ColorName.secondary200),
            ],
          ),
        ),

        suffixIcon: Container(
          height: 36,
          width: 36,
          padding: EdgeInsets.all(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onClear,
            child: Assets.images.auth.icClear.svg(),
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
        ),
      ),
    );
  }
}
