import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../widgets/profile_ui.dart';
import 'edit_profile_cubit.dart';

/// «Мій профіль»: the name (editable) and the phone (the login, so it
/// cannot be changed), the way to settings and sign-out.
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditProfileCubit>()..load(),
      child: BlocConsumer<EditProfileCubit, EditProfileState>(
        listenWhen: (previous, current) =>
            previous.savedCount != current.savedCount ||
            (current.failure != null && previous.failure != current.failure),
        listener: (context, state) {
          if (state.failure != null) {
            showFailureSnackBar(context, state.failure!);
          } else {
            showInfoSnackBar(context, 'Збережено');
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: AppBar(
            backgroundColor: ColorName.secondary100,
            title: Text('Мій профіль', style: AppText.title()),
          ),
          body: switch (state.status) {
            EditProfileStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            EditProfileStatus.loadFailure => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.failure!.message,
                      style: AppText.regular(color: ColorName.typography500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppButton.primary(
                      text: 'Спробувати ще раз',
                      onPressed: context.read<EditProfileCubit>().load,
                    ),
                  ],
                ),
              ),
            ),
            _ => _Form(state: state, onSignOut: onSignOut),
          },
          bottomNavigationBar:
              state.status == EditProfileStatus.editing ||
                  state.status == EditProfileStatus.saving
              ? SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.horizontalPadding,
                      8,
                      AppDimens.horizontalPadding,
                      12,
                    ),
                    child: AppButton.primary(
                      text: 'Зберегти',
                      loading: state.status == EditProfileStatus.saving,
                      onPressed: state.canSave
                          ? context.read<EditProfileCubit>().save
                          : null,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, required this.onSignOut});

  final EditProfileState state;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      children: [
        Center(child: InitialsAvatar(name: state.trimmed, size: 88)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _NameField(
                initial: state.savedName,
                showError: state.isChanged && !state.isNameValid,
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: formatProfilePhone(state.phone),
                readOnly: true,
                enableInteractiveSelection: false,
                style: AppText.medium(color: ColorName.typography500),
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  helperText: 'Це ваш логін, його змінити не можна',
                  suffixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: ColorName.secondary400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MenuCard(
          children: [
            MenuRow(
              icon: Icons.settings_outlined,
              tint: ColorName.secondary400,
              title: 'Налаштування',
              onTap: () => context.push(Routes.settings),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Away from everything else: leaving is not an everyday action.
        Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: ColorName.typography900,
              backgroundColor: ColorName.white,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(
              'Вийти із застосунку',
              style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
            ),
            onPressed: onSignOut,
          ),
        ),
      ],
    );
  }
}

/// The name field with a visible label; the error shows only once the
/// change makes the name too short, not while the field is untouched.
class _NameField extends StatelessWidget {
  const _NameField({required this.initial, required this.showError});

  final String initial;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      style: AppText.medium(),
      cursorColor: ColorName.primary400,
      decoration: InputDecoration(
        labelText: 'Ім’я',
        helperText: 'Його назве кухня, коли замовлення буде готове',
        errorText: showError ? 'Від 2 до 100 символів' : null,
        counterText: '',
      ),
      onChanged: context.read<EditProfileCubit>().nameChanged,
      onFieldSubmitted: (_) => context.read<EditProfileCubit>().save(),
    );
  }
}
