import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/di.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../profile/confirm_delete_dialog.dart';
import '../profile/delete_account_cubit.dart';
import '../widgets/profile_ui.dart';

/// «Налаштування»: notification permission (managed by the phone) and,
/// set apart at the bottom, account deletion.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            backgroundColor: ColorName.secondary100,
            title: Text('Налаштування', style: AppText.title()),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuCard(
                    children: [
                      MenuRow(
                        icon: Icons.notifications_active_outlined,
                        tint: ColorName.primary400,
                        title: 'Сповіщення',
                        subtitle: 'Дозвіл і звук — у налаштуваннях телефону',
                        onTap: openAppSettings,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _DeleteAccountButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
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
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: ColorName.red,
              backgroundColor: ColorName.redLight,
              minimumSize: const Size(48, 52),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              shape: const StadiumBorder(),
            ),
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ColorName.red,
                    ),
                  )
                : const Icon(Icons.delete_outline_rounded),
            label: Text(
              'Видалити акаунт',
              style: AppText.medium(
                color: ColorName.red,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            onPressed: busy
                ? null
                : () async {
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
