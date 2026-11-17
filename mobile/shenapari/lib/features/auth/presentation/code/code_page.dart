import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/placeholder_page.dart';

class CodePage extends StatelessWidget {
  const CodePage({
    super.key,
    required this.onSignedInAsNewUser,
    required this.onSignedInAsExistingUser,
  });

  final VoidCallback onSignedInAsNewUser;
  final VoidCallback onSignedInAsExistingUser;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Вхід: код із SMS',
      note: 'Справжнього входу ще немає. Кнопки імітують відповідь сервера.',
      actions: [
        PlaceholderAction('Увійти як новий користувач', onSignedInAsNewUser),
        PlaceholderAction(
          'Увійти як існуючий користувач',
          onSignedInAsExistingUser,
        ),
      ],
    );
  }
}
