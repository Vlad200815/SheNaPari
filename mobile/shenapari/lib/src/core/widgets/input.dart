import 'package:flutter/material.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';

class HintTextInputWidget extends StatelessWidget {
  const HintTextInputWidget({
    super.key,
    required this.title,
    required this.hint,
    this.value,
    this.isEnabled = true,
    this.onInputChanged,
    this.keyboardType,
    this.errorText,
    this.onTap,
  });

  final String title;
  final String hint;
  final String? value;
  final bool isEnabled;
  final Function(String)? onInputChanged;
  final TextInputType? keyboardType;
  final String? errorText;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ThemeText.poppinsMedium()),
        const SizedBox(height: 6),
        FilledInput(
          onInputChanged: (input) {
            onInputChanged?.call(input);
          },
          onTap: onTap,
          value: value,
          errorText: errorText,
          isEnabled: isEnabled,
          keyboardType: keyboardType,
          hint: hint,
        ),
      ],
    );
  }
}

class FilledInput extends StatefulWidget {
  const FilledInput({
    super.key,
    required this.hint,
    this.value,
    this.errorText,
    this.hasError = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.multiline,
    this.onInputChanged,
    this.onTap,
  });

  final String hint;
  final String? value;
  final String? errorText;
  final bool hasError;
  final bool isEnabled;
  final bool isReadOnly;
  final TextInputType? keyboardType;
  final Function(String)? onInputChanged;
  final Function()? onTap;

  @override
  State<FilledInput> createState() => _FilledInputState();
}

class _FilledInputState extends State<FilledInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderSide: widget.hasError
          ? const BorderSide(color: ColorName.red)
          : BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    );
    if (widget.value != null) {
      // _controller.text = widget.value!;
      final controllerSelection = _controller.selection;
      _controller = TextEditingController()..text = widget.value!;
      try {
        if (controllerSelection.isValid) {
          _controller.selection = controllerSelection;
        } else {
          _controller.selection = TextSelection(
            baseOffset: widget.value?.length ?? 0,
            extentOffset: widget.value?.length ?? 0,
          );
        }
      } catch (e) {}
    }
    return TextField(
      onTap: widget.onTap,
      onChanged: (input) {
        widget.onInputChanged?.call(input);
      },
      controller: _controller,
      keyboardType: widget.keyboardType,
      minLines: 1,
      maxLines: 10,
      readOnly: widget.isReadOnly,
      enabled: widget.isEnabled,
      style: ThemeText.poppinsMedium(),
      decoration: InputDecoration(
        errorText: widget.errorText,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorName.red),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: defaultBorder,
        focusedBorder: OutlineInputBorder(
          borderSide: widget.hasError
              ? const BorderSide(color: ColorName.red)
              : const BorderSide(color: ColorName.red),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: defaultBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: ColorName.primary400,
        hintText: widget.hint,
        hintStyle: ThemeText.poppinsMedium(),
      ),
    );
  }
}
