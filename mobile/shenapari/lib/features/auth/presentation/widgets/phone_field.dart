import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';

/// Ukrainian phone input: fixed `+380` prefix with a flag, then
/// `67 123 45 67`. [onChanged] gets the text as shown, with spaces.
class PhoneField extends StatefulWidget {
  const PhoneField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final _controller = TextEditingController();
  // One formatter per field: it keeps state about the current text.
  final _mask = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {'#': RegExp('[0-9]')},
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    _mask.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.phone,
      inputFormatters: [_mask],
      onChanged: widget.onChanged,
      cursorColor: ColorName.primary400,
      style: AppText.medium(),
      decoration: InputDecoration(
        hintText: '67 123 45 67',
        hintStyle: AppText.medium(color: ColorName.typography400),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.auth.icUA.svg(),
              const SizedBox(width: 12),
              Text('+380', style: AppText.medium()),
              const SizedBox(width: 12),
              Container(height: 40, width: 1, color: ColorName.secondary200),
            ],
          ),
        ),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: LocaleKeys.common_clear.tr(),
                  onPressed: _clear,
                  icon: Assets.images.auth.icClear.svg(),
                ),
        ),
      ),
    );
  }
}
