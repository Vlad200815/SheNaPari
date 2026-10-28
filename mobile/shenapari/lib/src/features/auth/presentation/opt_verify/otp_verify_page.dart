import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shenapari/gen/assets.gen.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/core/resource/theme_pin.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';
import 'package:shenapari/src/core/widgets/app_bar_item.dart';
import 'package:shenapari/src/core/widgets/button_item.dart';
import 'package:shenapari/src/core/widgets/image_view.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_page.dart';
import 'package:shenapari/src/features/profile/presentation/registration_profile/registration_profile_page.dart';

import '../../../../app/config.dart';
import '../../../../core/di/di.dart';
import '../widgets/widgets.dart';
import 'otp_verify_action.dart';
import 'otp_verify_event.dart';
import 'otp_verify_state.dart';
import 'otp_verify_view_model.dart';

class OtpVerifyPage
    extends
        BasePage<
          OtpVerifyViewModel,
          OtpVerifyState,
          OtpVerifyEvent,
          OtpVerifyAction
        > {
  final String phoneNumber;
  final int otpCodeExpiresInSeconds;

  OtpVerifyPage({
    super.key,
    required this.phoneNumber,
    required this.otpCodeExpiresInSeconds,
  });

  final String PAGE_STEP = "2";
  final String RESEND_TIME = "resend_time";
  final TextEditingController _pinPutController = TextEditingController();

  @override
  OtpVerifyViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return OtpVerifyViewModel(
      otpCodeExpiresInSeconds: otpCodeExpiresInSeconds,
      phoneNumber: phoneNumber,
      resendOtpCodeUseCase: di.get(),
      verifyOtpCodeUseCase: di.get(),
    );
  }

  @override
  void handleEvent(BuildContext context, OtpVerifyEvent event) {
    switch (event) {
      case PopOtpVerifyPageEvent _:
        context.pop(context);
      case OpenHomePageEvent _:
        HomePage.open(context);
      case OpenRegistrationProfilePageEvent _:
        RegistrationProfilePage.open(context);
    }
  }

  @override
  Widget createView(BuildContext context, OtpVerifyState state) {
    return Scaffold(
      appBar: AppBarItem(
        hasLeading: true,
        titleWidget: StepItem(
          currentStep: PAGE_STEP,
          maxSteps: Config.AUTH_MAX_STEPS,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false, // Ensures Spacer and centering work
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // --- Image Section (Responsive) ---
                        SizedBox(
                          height: constraints.maxHeight * 0.3,
                          child: ImageView(
                            url: Assets.images.auth.otpCode.path,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Heading Section ---
                        Text(
                          LocaleKeys.phone_auth_enter_6_digit_title.tr(),
                          style: ThemeText.poppinsHeading1(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          LocaleKeys.phone_auth_enter_6_digit_subtitle.tr(),
                          style: ThemeText.poppinsRegular(
                            color: ColorName.secondary500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // --- Phone & Edit Section ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${Config.BASE_UKRAINE_PHONE_NUMBER} $phoneNumber",
                              style: ThemeText.poppinsMedium(
                                color: ColorName.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => postAction(
                                context,
                                OnEditButtonPressedAction(),
                              ),
                              child: Text(
                                LocaleKeys.app_edit_button_text.tr(),
                                style: ThemeText.poppinsMedium(
                                  color: ColorName.primary400,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // --- Pinput Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Pinput(
                            controller: _pinPutController,
                            autofocus: true,
                            validator: (value) {
                              //TODO: implement validator logic
                              return value == '2222'
                                  ? null
                                  : 'Pin is incorrect';
                            },

                            length: 6, // Match your screenshot's 6 digits
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            // submittedPinTheme: submittedPinTheme,
                            onCompleted: (pin) {
                              debugPrint("---------------->  $pin");
                              //TODO: implement onCompleted logic
                            },
                          ),
                        ),

                        // --- Resend Section ---
                        Text(
                          LocaleKeys.phone_auth_resend_code_title.tr(
                            namedArgs: {
                              RESEND_TIME: state.resendTimeLeft.orEmpty(),
                            },
                          ),
                          style: ThemeText.poppinsMedium(
                            color: ColorName.black,
                          ),
                        ),
                        Visibility(
                          visible: state.isEnabledResend.orFalse(),
                          child: TextButton(
                            onPressed: () => postAction(
                              context,
                              OnResendButtonPressedAction(
                                pinPutController: _pinPutController,
                              ),
                            ),
                            child: Text(
                              LocaleKeys.phone_auth_send_code_again_button_text
                                  .tr(),
                              style: ThemeText.poppinsMedium(
                                color: ColorName.primary400,
                              ),
                            ),
                          ),
                        ),

                        // --- Dynamic Spacer ---
                        const Spacer(),

                        // --- Button Section ---
                        const SizedBox(height: 24),
                        ButtonItem.primary(
                          text: LocaleKeys.phone_auth_varify_button_text.tr(),
                          onTap: () => postAction(
                            context,
                            OnVerifyButtonPressedAction(
                              pinPutController: _pinPutController,
                            ),
                          ),
                        ),
                        const SizedBox(height: 112),
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
  static const String path = "/otp_verify";
  static const String name = "OtpVerify";

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      final extraData =
          state.extra as ({String phoneNumber, int otpExpiresInSeconds})?;

      final String? phoneNumber = extraData?.phoneNumber;
      final int? otpExpiresInSeconds = extraData?.otpExpiresInSeconds;

      return OtpVerifyPage(
        phoneNumber: phoneNumber.orEmpty(),
        otpCodeExpiresInSeconds: otpExpiresInSeconds.orZero(),
      );
    });
  }

  static Future<Object?> open(
    BuildContext context, {
    required String phoneNumber,
    required int otpExpiresInSeconds,
  }) {
    return context.push(
      Uri(path: path).toString(),
      extra: (
        phoneNumber: phoneNumber,
        otpExpiresInSeconds: otpExpiresInSeconds,
      ),
    );
  }
}
