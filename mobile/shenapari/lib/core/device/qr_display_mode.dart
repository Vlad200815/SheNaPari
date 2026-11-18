import 'dart:developer' as developer;

import 'package:no_screenshot/no_screenshot.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// What the phone does while a pickup QR is on screen: full brightness (the
/// scanner reads it faster), the screen does not go dark while the customer
/// waits in line, and screenshots / screen recording are blocked so a code
/// cannot be passed around.
abstract interface class QrDisplayMode {
  Future<void> enter();

  /// Back to the user's brightness and normal behaviour.
  Future<void> exit();
}

/// [QrDisplayMode] on a real device. Each part is best effort: if one
/// plugin is unavailable (simulator, desktop), the others still work.
class DeviceQrDisplayMode implements QrDisplayMode {
  @override
  Future<void> enter() => _all([
    () => ScreenBrightness.instance.setApplicationScreenBrightness(1),
    WakelockPlus.enable,
    NoScreenshot.instance.screenshotOff,
  ]);

  @override
  Future<void> exit() => _all([
    ScreenBrightness.instance.resetApplicationScreenBrightness,
    WakelockPlus.disable,
    NoScreenshot.instance.screenshotOn,
  ]);

  static Future<void> _all(List<Future<Object?> Function()> steps) async {
    for (final step in steps) {
      try {
        await step();
      } on Object catch (error) {
        developer.log('QR display mode step failed', name: 'qr', error: error);
      }
    }
  }
}
