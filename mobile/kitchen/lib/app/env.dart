import 'dart:io';

/// Environment config from `--dart-define-from-file=env/<name>.json`.
/// No secrets here: everything in the app binary can be extracted.
abstract final class Env {
  static const name = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const _apiBaseUrlFromDefine = String.fromEnvironment('API_BASE_URL');

  /// The backend address.
  ///
  /// Without `API_BASE_URL` the app talks to the developer's computer:
  /// the Android emulator sees it as `10.0.2.2`, the iOS simulator as
  /// `localhost`. A real phone needs the computer's Wi-Fi IP in
  /// `env/device.json` (see `env/device.example.json`).
  static String get apiBaseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) return _apiBaseUrlFromDefine;
    return Platform.isAndroid
        ? 'http://10.0.2.2:5041'
        : 'http://localhost:5041';
  }

  static bool get isProd => name == 'prod';
}
