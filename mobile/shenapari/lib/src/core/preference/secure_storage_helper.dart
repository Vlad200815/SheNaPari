import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shenapari/src/app/config.dart';

/// Helper class for [FlutterSecureStorage]
/// Used to set, get, delete JWT tokens securely
class SecureStorageHelper {
  static Future<String> getString(String key) async {
    final s = secureStorage;
    return await s.read(key: Config.VERSION_TYPE + key) ?? "";
  }

  static Future<void> setString(String key, String value) async {
    final s = secureStorage;
    return await s.write(key: Config.VERSION_TYPE + key, value: value);
  }

  static Future<void> delete(String key) async {
    final s = secureStorage;
    return await s.delete(key: Config.VERSION_TYPE + key);
  }

  // helper
  static FlutterSecureStorage get secureStorage => FlutterSecureStorage();
}
