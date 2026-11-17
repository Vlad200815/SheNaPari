import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/session/session_cubit.dart';
import '../core/ui/app_theme.dart';
import 'di.dart';

class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionCubit>(),
      child: MaterialApp.router(
        title: 'ШеНаПарі',
        theme: appTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
