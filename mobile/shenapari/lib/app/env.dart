/// Environment config from `--dart-define-from-file=env/<name>.json`.
/// No secrets here: everything in the app binary can be extracted.
abstract final class Env {
  static const name = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// The backend address. The default is the developer's computer as seen
  /// from the Android emulator. A real phone needs the computer's Wi-Fi IP:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5041`.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5041',
  );

  static bool get isProd => name == 'prod';
}
