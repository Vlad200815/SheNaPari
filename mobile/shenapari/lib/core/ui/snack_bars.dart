import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import '../result/failure.dart';
import 'app_text.dart';

/// Shows the failure text from the server (already in Ukrainian).
///
/// A soft card instead of a solid red bar: pale red background, thin red
/// border and an icon, so the error is clear without shouting. The text is
/// dark: red text on a pale background would fail the 4.5:1 contrast check.
void showFailureSnackBar(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // The card below draws everything; the bar itself stays invisible.
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        content: _ErrorCard(message: failure.message),
      ),
    );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorName.redLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorName.red.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: ColorName.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: ColorName.red, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppText.small(color: ColorName.typography900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
