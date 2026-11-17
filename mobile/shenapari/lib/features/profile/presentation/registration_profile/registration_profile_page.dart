import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/placeholder_page.dart';

class RegistrationProfilePage extends StatelessWidget {
  const RegistrationProfilePage({super.key, required this.onSaved});

  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Реєстрація: профіль',
      actions: [PlaceholderAction('Зберегти', onSaved)],
    );
  }
}
