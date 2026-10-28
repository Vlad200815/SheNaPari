import 'package:shenapari/src/app/config.dart';

/// Formate phoneNumber from "67 876 88 88" to "+380678768888" 13 characters
String ukrainianPhoneNumberFormater({required String rawPhoneNumber}) {
  return "${Config.BASE_UKRAINE_PHONE_NUMBER}${rawPhoneNumber.replaceAll(" ", "")}";
}
