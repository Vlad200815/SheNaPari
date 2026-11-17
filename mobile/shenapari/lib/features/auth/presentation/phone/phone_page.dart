import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/placeholder_page.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({super.key, required this.onCodeSent});

  final VoidCallback onCodeSent;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Вхід: номер телефону',
      actions: [PlaceholderAction('Отримати код', onCodeSent)],
    );
  }
}
