import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';

import 'preference_helper.dart';
import 'secure_storage_helper.dart';

class AppPreference {
  /// Terms of use
  static Future<LegalDocumentEntity?> get termsOfUse =>
      PreferencesHelper.getLegalDocument(key: Key.PREF_TERMS_OF_USE);

  static Future setTermsOfUse(LegalDocumentEntity entity) =>
      PreferencesHelper.setLegalDocument(
        key: Key.PREF_TERMS_OF_USE,
        entity: entity,
      );

  static Future<String> get acceptedTermsOfUseVersion =>
      PreferencesHelper.getString(Key.PREF_ACCEPTED_TERMS_OF_USE_VERSION);

  static Future setAcceptedTermsOfUseVersion(String value) =>
      PreferencesHelper.setString(
        Key.PREF_ACCEPTED_TERMS_OF_USE_VERSION,
        value,
      );

  /// Privacy Policy
  static Future<LegalDocumentEntity?> get privacyPolicy =>
      PreferencesHelper.getLegalDocument(key: Key.PREF_PRIVACY_POLICY);

  static Future setPrivacyPolicy(LegalDocumentEntity entity) =>
      PreferencesHelper.setLegalDocument(
        key: Key.PREF_PRIVACY_POLICY,
        entity: entity,
      );

  static Future<String> get acceptedPrivacyPolicyVersion =>
      PreferencesHelper.getString(Key.PREF_ACCEPTED_PRIVACY_POLICY_VERSION);

  static Future setAcceptedPrivacyPolicyVersion(String value) =>
      PreferencesHelper.setString(
        Key.PREF_ACCEPTED_PRIVACY_POLICY_VERSION,
        value,
      );

  // /// Terms of use current version
  // static Future<String> get termsOfUseVersion =>
  //     PreferencesHelper.getString(Key.PREF_TERMS_OF_USE_VERSION);
  // static Future setTermsOfUseVersion(String value) =>
  //     PreferencesHelper.setString(Key.PREF_TERMS_OF_USE_VERSION, value);
  //
  // /// Privacy Policy current version
  // static Future<String> get privacyPolicyVersion =>
  //     PreferencesHelper.getString(Key.PREF_PRIVACY_POLICY_VERSION);
  // static Future setPrivacyPolicyVersion(String value) =>
  //     PreferencesHelper.setString(Key.PREF_PRIVACY_POLICY_VERSION, value);
  //
  // /// Terms of use
  // static Future<String> get termsOfUse =>
  //     PreferencesHelper.getString(Key.PREF_TERMS_OF_USE_CONTENT);
  // static Future setTermsOfUse(String value) =>
  //     PreferencesHelper.setString(Key.PREF_TERMS_OF_USE_CONTENT, value);
  //
  // /// Privacy Policy
  // static Future<String> get privacyPolicy =>
  //     PreferencesHelper.getString(Key.PREF_PRIVACY_POLICY_CONTENT);
  // static Future setPrivacyPolicy(String value) =>
  //     PreferencesHelper.setString(Key.PREF_PRIVACY_POLICY_CONTENT, value);

  /// Is user authenticated
  static Future<bool> get isAuthenticated =>
      PreferencesHelper.getBool(Key.PREF_AUTHENTICATED);
  static Future setAuthenticated(bool value) =>
      PreferencesHelper.setBool(Key.PREF_AUTHENTICATED, value);

  /// Language
  static Future<String> get language =>
      PreferencesHelper.getString(Key.PREF_LANGUAGE);
  static Future setLanguage(String value) =>
      PreferencesHelper.setString(Key.PREF_LANGUAGE, value);

  /// FCM token
  static Future<String> get fcmToken =>
      PreferencesHelper.getString(Key.PREF_FCM_TOKEN);

  static Future setFcmToken(String value) =>
      PreferencesHelper.setString(Key.PREF_FCM_TOKEN, value);

  Future<void> clear() async {
    await Future.wait(<Future>[PreferencesHelper.clear()]);
  }

  /// Showed Intro
  static Future<bool> get isShowedIntro =>
      PreferencesHelper.getBool(Key.PREF_SHOWED_INTRO);
  static Future setShowedIntro(bool value) =>
      PreferencesHelper.setBool(Key.PREF_SHOWED_INTRO, value);
}

class AppSecureStorage {
  /// Save JWT (ACCESS & REFRESH) Tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorageHelper.setString(Key.SECURE_ACCESS_TOKEN, accessToken);
    await SecureStorageHelper.setString(Key.SECURE_REFRESH_TOKEN, refreshToken);
  }

  /// Get Access Token
  static Future<String> getAccessToken() async {
    return await SecureStorageHelper.getString(Key.SECURE_ACCESS_TOKEN);
  }

  /// Get Refresh Token
  static Future<String> getRefreshToken() async {
    return await SecureStorageHelper.getString(Key.SECURE_REFRESH_TOKEN);
  }

  /// Delete Tokens when log out
  static Future<void> deleteTokens() async {
    await SecureStorageHelper.delete(Key.SECURE_ACCESS_TOKEN);
    await SecureStorageHelper.delete(Key.SECURE_REFRESH_TOKEN);
  }
}

class Key {
  // Flutter Secure Storage
  static const String SECURE_ACCESS_TOKEN = "secure_access_token";
  static const String SECURE_REFRESH_TOKEN = "secure_refresh_token";

  // Shared Preferences
  static const String PREF_TERMS_OF_USE = "pref_terms_of_use";
  static const String PREF_PRIVACY_POLICY = "pref_privacy_policy";
  static const String PREF_ACCEPTED_TERMS_OF_USE_VERSION =
      "pref_accepted_terms_of_use_version";
  static const String PREF_ACCEPTED_PRIVACY_POLICY_VERSION =
      "pref_accepted_privacy_policy_version";

  static const String PREF_AUTHENTICATED = "pref_authenticated";
  static const String PREF_TOKEN = "pref_token";
  static const String PREF_FCM_TOKEN = "pref_fcm_token";
  static const String PREF_SHOWED_INTRO = "pref_showed_intro";
  static const String PREF_LANGUAGE = "pref_language";
}
