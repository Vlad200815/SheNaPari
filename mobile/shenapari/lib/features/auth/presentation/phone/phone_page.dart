import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../legal/domain/entities/legal_document.dart';
import '../widgets/auth_layout.dart';
import '../widgets/phone_field.dart';
import 'phone_cubit.dart';
import 'phone_state.dart';

/// Step 1 of sign-in: the phone number.
class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PhoneCubit>(),
      child: BlocListener<PhoneCubit, PhoneState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case PhoneStatus.sent:
              context.push(Routes.codeFor(state.phone));
            case PhoneStatus.failure:
              showFailureSnackBar(context, state.failure!);
            case PhoneStatus.editing || PhoneStatus.sending:
              break;
          }
        },
        child: Builder(
          builder: (context) => AuthLayout(
            step: 'Крок 1 з 2',
            image: Assets.images.auth.phoneAuth.image(fit: BoxFit.contain),
            title: 'Введіть номер телефону',
            subtitle: 'Ми надішлемо вам 6-значний код для підтвердження номера',
            form: PhoneField(
              onChanged: context.read<PhoneCubit>().phoneChanged,
            ),
            bottom: Column(
              children: [
                BlocBuilder<PhoneCubit, PhoneState>(
                  builder: (context, state) => AppButton.primary(
                    text: 'Продовжити',
                    loading: state.status == PhoneStatus.sending,
                    onPressed: state.isComplete
                        ? context.read<PhoneCubit>().submit
                        : null,
                  ),
                ),
                const SizedBox(height: 21),
                const _TermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "By continuing you agree to our Terms and Privacy Policy" with both
/// names as links.
class _TermsText extends StatefulWidget {
  const _TermsText();

  @override
  State<_TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<_TermsText> {
  late final _terms = _linkTo(LegalDocumentType.terms);
  late final _privacy = _linkTo(LegalDocumentType.privacy);

  TapGestureRecognizer _linkTo(LegalDocumentType type) =>
      TapGestureRecognizer()..onTap = () => context.push(Routes.legal(type));

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Brand yellow, semi-bold so the thin letters stay readable on white.
    final link = AppText.regular(
      color: ColorName.primary400,
    ).copyWith(fontWeight: FontWeight.w600);
    return Text.rich(
      TextSpan(
        style: AppText.regular(),
        children: [
          const TextSpan(text: 'Продовжуючи, ви погоджуєтеся з нашими '),
          TextSpan(
            text: 'Умовами використання',
            style: link,
            recognizer: _terms,
          ),
          const TextSpan(text: ' та '),
          TextSpan(
            text: 'Політикою конфіденційності',
            style: link,
            recognizer: _privacy,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
