import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import 'registration_cubit.dart';
import 'registration_state.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// The last sign-in step for a new customer: the name the kitchen calls out.
class RegistrationProfilePage extends StatelessWidget {
  const RegistrationProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegistrationCubit>(),
      child: BlocListener<RegistrationCubit, RegistrationState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == RegistrationStatus.failure) {
            showFailureSnackBar(context, state.failure!);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalPadding,
              ),
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      LocaleKeys.auth_name_title.tr(),
                      style: AppText.heading(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LocaleKeys.auth_name_subtitle.tr(),
                      style: AppText.regular(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      autofocus: true,
                      maxLength: 100,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      style: AppText.medium(),
                      cursorColor: ColorName.primary400,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.auth_name_hint.tr(),
                        hintStyle: AppText.medium(
                          color: context.colors.textTertiary,
                        ),
                        counterText: '',
                      ),
                      onChanged: context.read<RegistrationCubit>().nameChanged,
                      onSubmitted: (_) =>
                          context.read<RegistrationCubit>().submit(),
                    ),
                    const Spacer(),
                    BlocBuilder<RegistrationCubit, RegistrationState>(
                      builder: (context, state) => AppButton.primary(
                        text: LocaleKeys.common_continue.tr(),
                        loading: state.isBusy,
                        onPressed: state.canSubmit
                            ? context.read<RegistrationCubit>().submit
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
