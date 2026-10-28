import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';

class PreferencesHelper {
  static Future<void> setLegalDocument({
    required String key,
    required LegalDocumentEntity entity,
  }) async {
    final p = await prefs;

    final String jsonString = jsonEncode(entity.toJson());
    await p.setString(Config.VERSION_TYPE + key, jsonString);
  }

  static Future<LegalDocumentEntity?> getLegalDocument({
    required String key,
  }) async {
    final p = await prefs;
    final data = p.getString(Config.VERSION_TYPE + key);
    if (data == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(data);
    return LegalDocumentEntity(
      version: decoded['version'] ?? "",
      content: decoded['content'] ?? "",
    );
  }

  static Future<bool> getBool(String key) async {
    final p = await prefs;
    return p.getBool(Config.VERSION_TYPE + key) ?? false;
  }

  static Future setBool(String key, bool value) async {
    final p = await prefs;
    return p.setBool(Config.VERSION_TYPE + key, value);
  }

  static Future<int> getInt(String key) async {
    final p = await prefs;
    return p.getInt(Config.VERSION_TYPE + key) ?? 0;
  }

  static Future setInt(String key, int value) async {
    final p = await prefs;
    return p.setInt(Config.VERSION_TYPE + key, value);
  }

  static Future<String> getString(String key) async {
    final p = await prefs;
    return p.getString(Config.VERSION_TYPE + key) ?? '';
  }

  static Future setString(String key, String value) async {
    final p = await prefs;
    return p.setString(Config.VERSION_TYPE + key, value);
  }

  static Future<double> getDouble(String key) async {
    final p = await prefs;
    return p.getDouble(Config.VERSION_TYPE + key) ?? 0.0;
  }

  static Future setDouble(String key, double value) async {
    final p = await prefs;
    return p.setDouble(Config.VERSION_TYPE + key, value);
  }

  static Future<List<String>> getStringList(String key) async {
    final p = await prefs;
    return p.getStringList(Config.VERSION_TYPE + key) ?? [];
  }

  static Future setStringList(String key, List<String> value) async {
    final p = await prefs;
    return p.setStringList(Config.VERSION_TYPE + key, value);
  }

  static Future<Map<String, String?>> getStringMap(String key) async {
    final p = await prefs;
    final jsonString = p.getString(key) ?? '{}';
    final decodedMap = json.decode(jsonString) as Map<String, dynamic>;
    return decodedMap.map(
      (key, value) => MapEntry(Config.VERSION_TYPE + key, value as String?),
    );
  }

  static Future setStringMap(String key, Map<String, String?> value) async {
    final p = await prefs;
    final jsonString = json.encode(value);
    return p.setString(Config.VERSION_TYPE + key, jsonString);
  }

  static Future clear() async {
    final p = await prefs;
    return p.clear();
  }

  // helper
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
