import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/servies/url_handler_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'support_action.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportViewModel
    extends BaseViewModel<SupportState, SupportEvent, SupportAction>
    with UrlHandlerMixin {
  SupportViewModel() : super(SupportState());

  @override
  Future<void> onViewAction(
    SupportAction action,
    Emitter<SupportState> emitter,
  ) async {
    switch (action) {
      case OnTelegramButtonPressedAction action:
        await _handleOnTelegramButtonPressedAction(action, emitter);
      case OnEmailButtonPressedAction action:
        await _handleOnEmailButtonPressedAction(action, emitter);
      case OnPhoneButtonPressedAction action:
        await _handleOnPhoneButtonPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnTelegramButtonPressedAction]
  ///
  Future<void> _handleOnTelegramButtonPressedAction(
    OnTelegramButtonPressedAction action,
    Emitter<SupportState> emitter,
  ) async {
    loading(true);
    String urlString = "tg://resolve?domain=${Config.TELEGRAM_BOT_NAME}";

    if (!action.startParameter.isNullOrEmpty()) {
      urlString += "?start=${action.startParameter}";
    }

    final Uri telegramUri = Uri.parse(urlString);

    try {
      // Try to launch the link externally to force the native OS to open the Telegram app
      bool launched = await launchCustomScheme(telegramUri);
      // Fallback: If native app launch fails, open it in the standard web browser
      if (!launched) {
        String webUrlString = "https://t.me/${Config.TELEGRAM_BOT_NAME}";
        final Uri webTelegramUri = Uri.parse(webUrlString);

        debugPrint("Telegram app not installed. Launching web fallback.");
        await launchUrl(webTelegramUri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      debugPrint("Could not launch Telegram pipeline: $e");
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  ///
  /// Handle [OnEmailButtonPressedAction]
  ///
  Future<void> _handleOnEmailButtonPressedAction(
    OnEmailButtonPressedAction action,
    Emitter<SupportState> emitter,
  ) async {
    loading(true);
    try {
      final Uri emailUri = Uri(
        scheme: Config.MAILTO_SCHEME,
        path: Config.SUPPORT_EMAIL,
      );

      debugPrint("Tel Uri: $emailUri");
      bool isLaunched = await launchMail(emailUri);

      if (!isLaunched) {
        //TODO: replace with localization
        setThrowable("Failed");
      }
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  ///
  /// Handle [OnPhoneButtonPressedAction]
  ///
  Future<void> _handleOnPhoneButtonPressedAction(
    OnPhoneButtonPressedAction action,
    Emitter<SupportState> emitter,
  ) async {
    loading(true);
    try {
      // Build a structured URI token using the strict 'tel' scheme framework
      final Uri telUri = Uri(
        scheme: Config.TEL_SCHEME,
        path: Config.SUPPORT_PHONE_NUMBER,
      );
      debugPrint("Tel Uri: $telUri");

      bool isLaunched = await launchTel(telUri);

      if (!isLaunched) {
        //TODO: replace with localization
        setThrowable("Failed");
      }
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }
}
