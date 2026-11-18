import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
import 'package:flutter/widgets.dart';

/// Switches every text in the app to [languageCode] at once.
///
/// Texts read with `'key'.tr()` do not depend on the locale through the
/// context, so after the new texts are loaded every widget is rebuilt once.
/// States (cubits, scroll positions, the open screens) are kept.
Future<void> switchLanguage(BuildContext context, String languageCode) async {
  await context.setLocale(Locale(languageCode));
  void rebuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(rebuild);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
}
