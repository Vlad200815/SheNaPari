import '../../features/legal/domain/entities/legal_document.dart';

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

  /// One order, over the tabs.
  static const orderPattern = '/order/:id';
  static String order(String id) => '/order/$id';

  /// The order with the rating sheet open (from the «Як вам?» push).
  static String orderRate(String id) => '/order/$id?rate=1';
  static const more = '/more';

  /// Pushed over the tabs from «Більше».
  static const myProfile = '/profile';
  static const settings = '/settings';
  static const faq = '/faq';
  static const support = '/support';

  /// Pushed over the tabs: the QR of the active order for pickup.
  static const myQr = '/my-qr';

  /// «Мій QR» opened on one order (from its screen).
  static String myQrFor(String orderId) =>
      Uri(path: myQr, queryParameters: {'order': orderId}).toString();
  static const notifications = '/notifications';

  /// Dish details, over the tabs.
  static const dishPattern = '/dish/:id';
  static String dish(int id) => '/dish/$id';

  /// Choose a break and pay; pushed from the cart.
  static const checkout = '/checkout';

  /// Terms of use or privacy policy; open to everyone, signed in or not.
  static const legalPattern = '/legal/:type';
  static String legal(LegalDocumentType type) => '/legal/${type.name}';
}
