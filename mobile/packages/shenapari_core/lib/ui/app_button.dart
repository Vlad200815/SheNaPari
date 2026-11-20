import 'package:material_ui/material_ui.dart';

import '../gen/colors.gen.dart';
import 'app_text.dart';
import 'app_theme.dart';
import 'app_colors.dart';

enum _Kind { primary, outlined, destructive }

/// The app's button: orange gradient (primary), a grey border (outlined)
/// or solid red (destructive).
///
/// `onPressed: null` shows the disabled look; [loading] shows a spinner and
/// ignores taps, so a request cannot be sent twice.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  }) : _kind = _Kind.primary;

  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  }) : _kind = _Kind.outlined;

  /// Solid red: only for irreversible actions such as deleting the account.
  const AppButton.destructive({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  }) : _kind = _Kind.destructive;

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final _Kind _kind;

  static final _radius = BorderRadius.circular(AppDimens.radius);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (decoration, textColor) = switch (_kind) {
      _Kind.primary when enabled || loading => (
        BoxDecoration(
          borderRadius: _radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorName.primary400, ColorName.orange],
          ),
        ),
        ColorName.white,
      ),
      _Kind.primary => (
        BoxDecoration(borderRadius: _radius, color: context.colors.border),
        context.colors.textSecondary,
      ),
      _Kind.destructive => (
        BoxDecoration(borderRadius: _radius, color: ColorName.red),
        ColorName.white,
      ),
      _Kind.outlined => (
        BoxDecoration(
          borderRadius: _radius,
          border: Border.all(color: context.colors.border),
        ),
        context.colors.textSecondary,
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: _radius,
        child: Ink(
          height: 52,
          decoration: decoration,
          child: Center(
            child: loading
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Text(text, style: AppText.button(color: textColor)),
          ),
        ),
      ),
    );
  }
}
