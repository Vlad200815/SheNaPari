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

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    final accent = AppText.regular(color: ColorName.primary500);
    return Text.rich(
      TextSpan(
        style: AppText.regular(),
        children: [
          const TextSpan(text: 'Продовжуючи, ви погоджуєтеся з нашими '),
          TextSpan(text: 'Умовами використання', style: accent),
          const TextSpan(text: ' та '),
          TextSpan(text: 'Політикою конфіденційності', style: accent),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
