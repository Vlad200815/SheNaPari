import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shenapari/generated/locale_keys.g.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.app_errors_email_val_default.tr();
    }

    if (!EmailValidator.validate(value)) {
      return LocaleKeys.app_errors_email_val.tr();
    }

    return null;
  }

  static String? signInPassword(String? value) {
    if (value.isNullOrEmpty()) {
      return LocaleKeys.app_errors_password_val_default.tr();
    }
    return null;
  }

  static String? password(String? value) {
    if (value.isNullOrEmpty()) {
      return LocaleKeys.app_errors_password_val_default.tr();
    }

    //I check above value can not be null so It will not crash
    if (value!.length < 8) {
      return LocaleKeys.app_errors_password_val_min_characters.tr();
    }

    if (!ValidatorsRegExp.PASSWORD_REGEXP_UPPER_LETTER.hasMatch(value)) {
      return LocaleKeys.app_errors_password_val_uppercase_letter.tr();
    }

    if (!ValidatorsRegExp.PASSWORD_REGEXP_ONE_NUM.hasMatch(value)) {
      return LocaleKeys.app_errors_password_val_min_one_digit.tr();
    }

    return null;
  }

  static String? userName(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.app_errors_user_name_default.tr();
    }
    final regex = ValidatorsRegExp.USER_NAME_REGEXP;
    if (!regex.hasMatch(value)) {
      return LocaleKeys.app_errors_user_name.tr();
    }
    return null;
  }
}

class ValidatorsRegExp {
  static final EMAIL_REGEXP = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  static final PASSWORD_REGEXP_UPPER_LETTER = RegExp(r'[A-Z]');
  static final PASSWORD_REGEXP_ONE_NUM = RegExp(r"[0-9]");
  static final USER_NAME_REGEXP = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
}
