/// All paths in one place. Screens navigate by these constants and never
/// import pages of other features.
abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const phone = '/auth/phone';
  static const code = '/auth/code';

  /// The code screen for [phone] (`+380XXXXXXXXX`).
  static String codeFor(String phone) =>
      Uri(path: code, queryParameters: {'phone': phone}).toString();
  static const registrationProfile = '/registration-profile';
  static const home = '/home';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';

  /// Pushed over the tabs: the QR of the active order for pickup.
  static const myQr = '/my-qr';
  static const notifications = '/notifications';
}
