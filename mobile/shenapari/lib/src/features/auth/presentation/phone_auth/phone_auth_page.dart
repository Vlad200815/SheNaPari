import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/gen/assets.gen.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';
import 'package:shenapari/src/features/info/presentation/legal/legal_page.dart';

import '../../../../core/widgets/widgets.dart';
import '../opt_verify/otp_verify_page.dart';
import '../widgets/widgets.dart';
import 'phone_auth_action.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';
import 'phone_auth_view_model.dart';

class PhoneAuthPage
    extends
        BasePage<
          PhoneAuthViewModel,
          PhoneAuthState,
          PhoneAuthEvent,
          PhoneAuthAction
        > {
  final String PAGE_STEP = "1";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void onDestroy() {
    _phoneNumberController.dispose();
    super.onDestroy();
  }

  @override
  PhoneAuthViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return PhoneAuthViewModel(sendOtpCodeUseCase: di.get());
  }

  @override
  void handleEvent(BuildContext context, PhoneAuthEvent event) {
    switch (event) {
      case OpenTermsOfUsePageEvent _:
        LegalPage.open(context, documentType: DocumentType.termsOfUse);
      case OpenPrivacyPolicyPageEvent _:
        LegalPage.open(context, documentType: DocumentType.privacyPolicy);
      case OpenOtpVerifyPageEvent event:
        OtpVerifyPage.open(
          context,
          phoneNumber: _phoneNumberController.text,
          otpExpiresInSeconds: event.otpCodeExpiresInSeconds,
        );
    }
  }

  // Helper to keep code clean
  Widget _buildTermsText(BuildContext context) {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: LocaleKeys.phone_auth_terms_and_privacy_start_text.tr(),
        style: ThemeText.poppinsRegular(fontWeight: FontWeight.w400),
        children: [
          TextSpan(
            text: " ${LocaleKeys.phone_auth_terms_of_use_hyper_text.tr()}",
            style: ThemeText.poppinsRegular(color: ColorName.primary400),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  postAction(context, OnTermsOfUseHyperTextPressedAction()),
          ),
          TextSpan(text: " ${LocaleKeys.phone_auth_and_text.tr()}"),
          TextSpan(
            text: " ${LocaleKeys.phone_auth_privacy_policy_hyper_text.tr()}",
            style: ThemeText.poppinsRegular(color: ColorName.primary400),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  postAction(context, OnPrivacyPolicyHyperTextPressedAction()),
          ),
        ],
      ),
    );
  }

  @override
  Widget createView(BuildContext context, PhoneAuthState state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppPreference.setAuthenticated(false);
          await AppPreference.setShowedIntro(false);
          debugPrint("TEST: clear isAith and isIntroShown");

          // postAction(context, TestLoaderAction());
        },
        child: Text("Test"),
      ),
      appBar: AppBarItem(
        titleWidget: StepItem(
          currentStep: PAGE_STEP,
          maxSteps: Config.AUTH_MAX_STEPS,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              // physics ensures it only scrolls if it actually needs to
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody:
                      false, // This is the secret for centering + scrolling
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
                    ),
                    child: Column(
                      children: [
                        // --- Image Section ---
                        // Use a fixed height or percentage so it doesn't fight for space
                        const SizedBox(height: 20),
                        SizedBox(
                          height:
                              constraints.maxHeight *
                              0.3, // 30% of screen height
                          child: ImageView(
                            url: Assets.images.auth.phoneAuth.path,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Text Section ---
                        Text(
                          LocaleKeys.phone_auth_enter_your_phone_title.tr(),
                          style: ThemeText.poppinsHeading1(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          LocaleKeys.phone_auth_enter_your_phone_subtitle.tr(),
                          style: ThemeText.poppinsRegular(),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // --- Input Section ---
                        Form(
                          key: _formKey,
                          child: PhoneNumberInputItem(
                            onChanged: (phoneNumber) => postAction(
                              context,
                              OnInputFormChangedAction(
                                phoneNumber: phoneNumber,
                              ),
                            ),
                            controller: _phoneNumberController,
                            onClear: () => postAction(
                              context,
                              OnClearInputButtonPressedAction(
                                phoneNumberController: _phoneNumberController,
                              ),
                            ),
                          ),
                        ),

                        // --- Dynamic Spacer ---
                        // This pushes the button to the bottom if there is space,
                        // but disappears when the keyboard opens.
                        const Spacer(),
                        const SizedBox(height: 8),

                        // --- Bottom Section ---
                        state.isEnabledContinueButton.orFalse()
                            ? ButtonItem.primary(
                                text: LocaleKeys.app_continue_button_text.tr(),
                                onTap: () => postAction(
                                  context,
                                  OnContinueButtonPressedAction(
                                    phoneNumber: _phoneNumberController.text,
                                  ),
                                ),
                              )
                            : ButtonItem.secondary(
                                text: LocaleKeys.app_continue_button_text.tr(),
                              ),

                        const SizedBox(height: 21),
                        _buildTermsText(context),
                        const SizedBox(height: 38),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //
  // Navigation
  //
  static const String path = "/phone_auth";
  static const String name = "PhoneAuth";

  PhoneAuthPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return PhoneAuthPage();
    });
  }

  static Future<Object?> open(BuildContext context) {
    return context.push(Uri(path: path).toString());
  }
}
