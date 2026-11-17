import 'package:material_ui/material_ui.dart';

/// A stand-in for a screen that is not designed yet: a title, an optional
/// note and buttons that let us walk through the navigation.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    this.note,
    this.actions = const [],
  });

  final String title;
  final String? note;
  final List<PlaceholderAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Заглушка', style: theme.textTheme.labelLarge),
              if (note != null) ...[
                const SizedBox(height: 8),
                Text(note!, textAlign: TextAlign.center),
              ],
              for (final action in actions) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: action.onPressed,
                  child: Text(action.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderAction {
  const PlaceholderAction(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;
}
