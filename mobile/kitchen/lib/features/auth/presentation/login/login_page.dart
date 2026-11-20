import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_logo.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../../app/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/kitchen_button.dart';
import 'login_cubit.dart';
import 'login_state.dart';

/// The first screen of the kitchen app: e-mail and password, no sign-up
/// (the admin creates staff). On a tablet the brand fills the left half.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _tabletWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth >= _tabletWidth
              ? Row(
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: context.colors.surface,
                        child: const _Brand(),
                      ),
                    ),
                    const Expanded(
                      child: _FormArea(showHeader: false, maxWidth: 420),
                    ),
                  ],
                )
              : const _FormArea(showHeader: true, maxWidth: 460),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(width: 140),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.kitchen.tr(),
              style: AppText.heading().copyWith(fontSize: 30),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                LocaleKeys.login_brand_text.tr(),
                textAlign: TextAlign.center,
                style: AppText.regular(color: context.colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormArea extends StatelessWidget {
  const _FormArea({required this.showHeader, required this.maxWidth});

  /// The logo above the form: on a phone, where there is no brand half.
  final bool showHeader;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: _Form(showHeader: showHeader),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.showHeader});

  final bool showHeader;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final error = state.status == LoginStatus.failure
            ? state.failure?.text
            : null;
        return AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHeader) ...[
                const Center(child: AppLogo()),
                const SizedBox(height: 14),
              ],
              Text(
                LocaleKeys.login_title.tr(),
                textAlign: widget.showHeader
                    ? TextAlign.center
                    : TextAlign.start,
                style: AppText.title().copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                LocaleKeys.login_subtitle.tr(),
                textAlign: widget.showHeader
                    ? TextAlign.center
                    : TextAlign.start,
                style: AppText.small(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 28),
              TextField(
                key: const ValueKey('email'),
                onChanged: cubit.emailChanged,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                style: AppText.regular(),
                decoration: InputDecoration(
                  labelText: LocaleKeys.login_email.tr(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('password'),
                onChanged: cubit.passwordChanged,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => cubit.submit(),
                style: AppText.regular(),
                decoration: InputDecoration(
                  labelText: LocaleKeys.login_password.tr(),
                  // The reason right under the field, not in a pop-up.
                  errorText: error,
                  errorMaxLines: 2,
                  suffixIcon: TextButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    child: Text(
                      _obscure
                          ? LocaleKeys.login_show.tr()
                          : LocaleKeys.login_hide.tr(),
                      style: AppText.small(color: context.colors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              KitchenButton(
                text: LocaleKeys.login_submit.tr(),
                loading: state.status == LoginStatus.sending,
                onPressed: state.canSubmit ? cubit.submit : null,
              ),
              const SizedBox(height: 16),
              Text(
                LocaleKeys.login_forgot.tr(),
                textAlign: TextAlign.center,
                style: AppText.small(color: context.colors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
