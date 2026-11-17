import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The tab bar around the main screens. Each tab keeps its own stack.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again returns to its first screen.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Головна'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Профіль'),
        ],
      ),
    );
  }
}
