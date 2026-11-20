import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_theme.dart';

import '../core/l10n/l10n.dart';

/// «ШеНаПарі Кухня». Always dark: the screen is on all day, a dark one
/// does not glare, and the status colours read best on it.
class KitchenApp extends StatelessWidget {
  const KitchenApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (_) => LocaleKeys.app_title.tr(),
      theme: appDarkTheme,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        EasyLocalization.of(context)!.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: child!,
      ),
    );
  }
}
