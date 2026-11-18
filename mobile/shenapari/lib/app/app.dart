import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
      child: MaterialApp.router(
        title: 'ШеНаПарі',
        theme: appTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        // «Вимкнути анімації» in the app adds to the phone's own setting:
        // every animation in the app checks MediaQuery.disableAnimations.
        builder: (context, child) => ListenableBuilder(
          listenable: sl<AppPrefs>(),
          builder: (context, _) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                disableAnimations:
                    media.disableAnimations || sl<AppPrefs>().reduceMotion,
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
