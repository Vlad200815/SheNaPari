import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';

/// A code input drawn as [length] boxes. Under the hood it is one invisible
/// [TextField] on top of the boxes, so the keyboard, paste and SMS autofill
/// work as in any text field.
class CodeField extends StatefulWidget {
  const CodeField({
    super.key,
    required this.controller,
    required this.length,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onCompleted;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([widget.controller, _focus]),
          builder: (context, _) {
            final code = widget.controller.text;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < widget.length; i++)
                  _Box(
                    digit: i < code.length ? code[i] : '',
                    active: _focus.hasFocus && i == code.length,
                  ),
              ],
            );
          },
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              onChanged: (code) {
                if (code.length == widget.length) widget.onCompleted(code);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.active});

  final String digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? ColorName.primary400 : ColorName.secondary200,
        ),
      ),
      child: Text(digit, style: AppText.medium()),
    );
  }
}
