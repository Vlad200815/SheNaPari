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
import '../../../legal/domain/entities/legal_document.dart';
import 'confirm_delete_dialog.dart';
import 'delete_account_cubit.dart';

/// Documents, sign-out and, set apart at the bottom, account deletion.
/// The full profile (name, order history) comes in a later step.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeleteAccountCubit>(),
      child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == DeleteAccountStatus.failure) {
            showFailureSnackBar(context, state.failure!);
          }
        },
        child: Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: AppBar(
            title: Text('Профіль', style: AppText.title()),
            backgroundColor: ColorName.secondary100,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimens.horizontalPadding),
            children: [
              _Section(
                children: [
                  for (final type in LegalDocumentType.values)
                    _LinkTile(
                      icon: type == LegalDocumentType.terms
                          ? Icons.description_outlined
                          : Icons.privacy_tip_outlined,
                      title: type.title,
                      onTap: () => context.push(Routes.legal(type)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton.outlined(text: 'Вийти', onPressed: onSignOut),
              const SizedBox(height: 40),
              // Dangerous action: red and away from everything else.
              const _DeleteAccountButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
      builder: (context, state) {
        final busy =
            state.status == DeleteAccountStatus.deleting ||
            state.status == DeleteAccountStatus.deleted;
        return Center(
          child: busy
              ? const SizedBox.square(
                  dimension: 48,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ColorName.red,
                    ),
                  ),
                )
              : TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: ColorName.red,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(
                    'Видалити акаунт',
                    style: AppText.medium(color: ColorName.red),
                  ),
                  onPressed: () async {
                    final cubit = context.read<DeleteAccountCubit>();
                    if (await confirmDeleteAccount(context)) {
                      await cubit.delete();
                    }
                  },
                ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorName.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 56,
                color: ColorName.secondary200,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 56,
      leading: Icon(icon, color: ColorName.secondary500),
      title: Text(title, style: AppText.medium()),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: ColorName.secondary400,
      ),
    );
  }
}
