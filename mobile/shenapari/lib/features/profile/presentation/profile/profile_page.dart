import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/placeholder_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Профіль',
      actions: [PlaceholderAction('Вийти', onSignOut)],
    );
  }
}
