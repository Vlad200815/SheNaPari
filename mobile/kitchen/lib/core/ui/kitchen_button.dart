import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';

/// The kitchen's main button: solid brand yellow with dark text (white on
/// yellow is too faint across a kitchen), 56 high for wet or gloved hands.
/// `onPressed: null` is the disabled look; [loading] shows a spinner.
class KitchenButton extends StatelessWidget {
  const KitchenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: enabled || loading ? ColorName.primary400 : context.colors.fill,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: loading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ColorName.black,
                    ),
                  )
                : Text(
                    text,
                    style: AppText.button(
                      color: enabled
                          ? ColorName.black
                          : context.colors.textTertiary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
