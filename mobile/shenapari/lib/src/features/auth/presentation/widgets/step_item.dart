import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';

class StepItem extends StatelessWidget {
  final String currentStep, maxSteps;

  const StepItem({
    super.key,
    required this.currentStep,
    required this.maxSteps,
  });

  final String CURRENT_STEP = "current_step";
  final String MAX_STEPS = "max_steps";

  @override
  Widget build(context) {
    return Text(
      LocaleKeys.phone_auth_step_title.tr(
        namedArgs: {CURRENT_STEP: currentStep, MAX_STEPS: maxSteps},
      ),
      //TODO: change style to the right text style
      style: ThemeText.poppinsMedium(color: ColorName.black),
    );
  }
}
