import 'package:flutter/foundation.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:url_launcher/url_launcher.dart';

mixin UrlHandlerMixin {
  /// Main entry point to handle any URL, scheme, or deep link.
  Future<bool> launchLink(String rawUrl, {LaunchMode? preferredMode}) async {
    debugPrint("Attempting to launch: $rawUrl");

    // 1. Sanitize and parse the URL safely
    final String sanitizedUrl = rawUrl.trim();
    if (sanitizedUrl.isEmpty) return false;

    final Uri? uri = Uri.tryParse(sanitizedUrl);
    if (uri == null) {
      debugPrint("Could not parse URL: $sanitizedUrl");
      return false;
    }

    // 2. Determine the best launch strategy based on the scheme
    try {
      switch (uri.scheme) {
        case Config.HTTP_SCHEME:
        case Config.HTTPS_SCHEME:
          return await _launchWebUrl(uri, preferredMode);

        case Config.MAILTO_SCHEME:
          return await launchMail(uri);

        case Config.TEL_SCHEME:
          return await launchTel(uri);

        case Config.SMS_SCHEME:
          return await _launchSms(uri);

        default:
          // Handles custom app schemes/deep links (e.g., whatsapp://, fb://)
          return await launchCustomScheme(uri);
      }
    } catch (e, stackTrace) {
      debugPrint("Error launching $rawUrl: $e");
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  /// Handles standard websites and web views
  Future<bool> _launchWebUrl(Uri uri, LaunchMode? preferredMode) async {
    // Default to inAppBrowserView for a seamless user experience,
    // fallback to external application if preferred.
    final mode = preferredMode ?? LaunchMode.inAppBrowserView;

    return await launchUrl(uri, mode: mode);
  }

  /// Handles mailto links with safe encoding
  Future<bool> launchMail(Uri uri) async {
    // mailto links can fail if they contain raw spaces or unencoded characters.
    // Using Uri(scheme: 'mailto'...) guarantees proper query encoding.
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  /// Handles phone calls
  Future<bool> launchTel(Uri uri) async {
    // canLaunchUrl is reliable for tel/sms if declared in Manifest/Info.plist
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
    debugPrint("Device does not support phone calls.");
    return false;
  }

  /// Handles SMS/Text messages
  Future<bool> _launchSms(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
    debugPrint("Device does not support sending SMS.");
    return false;
  }

  /// Handles Custom App Deep links (e.g., slack://, tg://)
  Future<bool> launchCustomScheme(Uri uri) async {
    // For external apps, externalApplication or platformDefault is mandatory.
    // canLaunchUrl is critical here to check if the third-party app is installed.
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    }
    debugPrint("No app installed to handle custom scheme: ${uri.scheme}");
    return false;
  }
}
