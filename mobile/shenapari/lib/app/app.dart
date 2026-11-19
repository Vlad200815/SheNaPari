import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/l10n.dart';
import '../core/session/session_cubit.dart';
import '../core/storage/app_prefs.dart';
import '../core/ui/app_theme.dart';
import '../features/cart/presentation/cart_cubit.dart';
import 'di.dart';

class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SessionCubit>()),
        // The shared cart: a singleton, so `.value` keeps it alive.
        BlocProvider.value(value: sl<CartCubit>()),
      ],
      // «Тема» in the settings: the whole app follows AppPrefs at once.
      child: ListenableBuilder(
        listenable: sl<AppPrefs>(),
        builder: (context, _) => MaterialApp.router(
          onGenerateTitle: (_) => LocaleKeys.app_name.tr(),
          theme: appTheme,
          darkTheme: appDarkTheme,
          themeMode: sl<AppPrefs>().themeMode,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          // material_ui's own delegates: its widgets look up material_ui's
          // MaterialLocalizations, not flutter_localizations' one.
          localizationsDelegates: [
            EasyLocalization.of(context)!.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          // «Вимкнути анімації» in the app adds to the phone's own setting:
          // every animation in the app checks MediaQuery.disableAnimations.
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final dark = Theme.of(context).brightness == Brightness.dark;
            // Status bar icons for screens without an app bar (home, «Більше»):
            // light on the dark theme, dark on the light one.
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: MediaQuery(
                data: media.copyWith(
                  disableAnimations:
                      media.disableAnimations || sl<AppPrefs>().reduceMotion,
                ),
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}
