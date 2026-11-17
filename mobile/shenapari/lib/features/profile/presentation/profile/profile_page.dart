import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/ui/placeholder_page.dart';
import '../../../legal/domain/entities/legal_document.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Профіль',
      actions: [
        for (final type in LegalDocumentType.values)
          PlaceholderAction(type.title, () => context.push(Routes.legal(type))),
        PlaceholderAction('Вийти', onSignOut),
      ],
    );
  }
}
