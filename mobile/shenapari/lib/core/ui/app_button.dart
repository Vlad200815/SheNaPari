import 'package:material_ui/material_ui.dart';

import '../../gen/colors.gen.dart';
import 'app_text.dart';
import 'app_theme.dart';

enum _Kind { primary, outlined }

/// The app's button: orange gradient (primary) or a grey border (outlined).
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
        BoxDecoration(borderRadius: _radius, color: ColorName.typography200),
        ColorName.typography500,
      ),
      _Kind.outlined => (
        BoxDecoration(
          borderRadius: _radius,
          border: Border.all(color: ColorName.secondary200),
        ),
        ColorName.secondary500,
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
