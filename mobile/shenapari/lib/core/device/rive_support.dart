import 'dart:developer' as developer;

import 'package:rive/rive.dart' as rive;

/// What the Rive runtime said at start-up, so a Rive animation knows how to
/// draw — or that it can't and its drawn stand-in shows instead.
abstract final class RiveSupport {
  /// Null: no Rive at all.
  static rive.Factory? factory;

  static Future<void> init() async {
    switch (await rive.RiveNative.init()) {
      case rive.RiveNativeReady():
        factory = rive.Factory.rive;
      // No Rive renderer on this device: Flutter's canvas draws it.
      case rive.RiveRendererUnavailable(:final reason):
        factory = rive.Factory.flutter;
        developer.log('Rive draws with Flutter: $reason', name: 'rive');
      case rive.RiveNativeInitFailed(:final message, :final error):
        factory = null;
        developer.log(message, name: 'rive', error: error);
    }
  }
}
