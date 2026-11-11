import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:shenapari/src/app/config.dart";
import "package:shenapari/src/app/navigation.dart";
import "package:shenapari/src/core/preference/app_preference.dart";
import "package:shenapari/src/core/resource/theme.dart";
import "package:shenapari/src/core/widgets/app_snack_bar.dart";


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  late final _router = Navigation.router();
  Locale? _savedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (locale != _savedLocale) {
      _savedLocale = locale;
      AppPreference.setLanguage(locale.languageCode);
    }
  }


  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: Config.APP_TITLE,
    theme: lightTheme,
    darkTheme: darkTheme,
    scaffoldMessengerKey: scaffoldMessengerKey,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    routerConfig: _router,
    debugShowCheckedModeBanner: false,
  );

}
