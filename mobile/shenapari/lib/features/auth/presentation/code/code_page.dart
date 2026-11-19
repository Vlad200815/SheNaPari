import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/auth_layout.dart';
import '../widgets/code_field.dart';
import 'code_cubit.dart';
import 'code_state.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// Step 2 of sign-in: the code from the SMS for [phone].
class CodePage extends StatelessWidget {
  const CodePage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CodeCubit>(param1: phone),
      child: _CodeView(phone: phone),
    );
  }
}

class _CodeView extends StatefulWidget {
  const _CodeView({required this.phone});

  final String phone;

  @override
  State<_CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<_CodeView> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CodeCubit>();
    return BlocListener<CodeCubit, CodeState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CodeStatus.failure) {
          _code.clear();
          showFailureSnackBar(context, state.failure!);
        }
      },
      child: AuthLayout(
        step: LocaleKeys.auth_step.tr(
          namedArgs: {'current': '2', 'total': '2'},
        ),
        image: Assets.images.auth.otpCode.image(fit: BoxFit.contain),
        title: LocaleKeys.auth_code_title.tr(),
        subtitle: LocaleKeys.auth_code_subtitle.tr(
          namedArgs: {'phone': formatPhone(widget.phone)},
        ),
        form: CodeField(
          controller: _code,
          length: CodeCubit.codeLength,
          onCompleted: cubit.verify,
        ),
        bottom: BlocBuilder<CodeCubit, CodeState>(
          builder: (context, state) => Column(
            children: [
              ListenableBuilder(
                listenable: _code,
                builder: (context, _) => AppButton.primary(
                  text: LocaleKeys.auth_confirm.tr(),
                  loading:
                      state.status == CodeStatus.verifying ||
                      state.status == CodeStatus.success,
                  onPressed: _code.text.length == CodeCubit.codeLength
                      ? () => cubit.verify(_code.text)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _ResendButton(state: state, onResend: cubit.resend),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({required this.state, required this.onResend});

  final CodeState state;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (state.resendIn > 0) {
      final seconds = state.resendIn.toString().padLeft(2, '0');
      return Text(
        LocaleKeys.auth_resend_in.tr(namedArgs: {'seconds': seconds}),
        style: AppText.regular(color: context.colors.textSecondary),
      );
    }
    return TextButton(
      onPressed: state.isBusy ? null : onResend,
      child: Text(
        LocaleKeys.auth_resend.tr(),
        style: AppText.medium(color: ColorName.primary500),
      ),
    );
  }
}

/// `+380671234567` → `+380 67 123 45 67`.
String formatPhone(String phone) {
  final match = RegExp(
    r'^\+380(\d{2})(\d{3})(\d{2})(\d{2})$',
  ).firstMatch(phone);
  if (match == null) return phone;
  return '+380 ${match[1]} ${match[2]} ${match[3]} ${match[4]}';
}
