import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'root_state.dart';

class RootPage extends StatefulWidget {
  const RootPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<RootPage> createState() => RootState();
}
