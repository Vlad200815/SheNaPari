import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/di.dart';
import '../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/l10n/switch_language.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari_core/ui/snack_bars.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import '../profile/confirm_delete_dialog.dart';
import '../profile/delete_account_cubit.dart';
import '../widgets/profile_ui.dart';
import 'language_menu.dart';
import 'theme_menu.dart';
import 'settings_cubit.dart';
import 'package:shenapari_core/ui/app_colors.dart';

/// «Налаштування»: order push on/off, the phone's notification permission,
/// «Вимкнути анімації» and,
/// set apart at the bottom, account deletion.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DeleteAccountCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()..load()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == DeleteAccountStatus.failure) {
                showFailureSnackBar(context, state.failure!);
              }
            },
          ),
          // A new language: switch every text in the app at once.
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                previous.languageCode != current.languageCode,
            listener: (context, state) =>
                switchLanguage(context, state.languageCode),
          ),
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                current.failure != null && previous.failure != current.failure,
            listener: (context, state) =>
                showFailureSnackBar(context, state.failure!),
          ),
        ],
        child: Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBar(
            backgroundColor: context.colors.background,
            title: Text(LocaleKeys.settings_title.tr(), style: AppText.title()),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      final cubit = context.read<SettingsCubit>();
                      final orderPush = state.orderPush;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MenuCard(
                            children: [
                              SwitchRow(
                                icon: Icons.notifications_active_outlined,
                                tint: ColorName.primary400,
                                title: LocaleKeys.settings_order_push.tr(),
                                subtitle: LocaleKeys.settings_order_push_text
                                    .tr(),
                                value: orderPush ?? true,
                                onChanged: orderPush == null
                                    ? null
                                    : cubit.setOrderPush,
                              ),
                              MenuRow(
                                icon: Icons.settings_suggest_outlined,
                                tint: context.colors.iconMuted,
                                title: LocaleKeys.settings_permission.tr(),
                                subtitle: LocaleKeys.settings_permission_text
                                    .tr(),
                                onTap: openAppSettings,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MenuCard(
                            children: [
                              LanguageRow(
                                current: state.language,
                                onPicked: cubit.setLanguage,
                              ),
                              ThemeRow(
                                current: state.themeMode,
                                onPicked: cubit.setThemeMode,
                              ),
                              SwitchRow(
                                icon: Icons.motion_photos_off_outlined,
                                tint: ColorName.blue,
                                title: LocaleKeys.settings_reduce_motion.tr(),
                                subtitle: LocaleKeys.settings_reduce_motion_text
                                    .tr(),
                                value: state.reduceMotion,
                                onChanged: cubit.setReduceMotion,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
              backgroundColor: context.colors.dangerSoft,
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
              LocaleKeys.settings_delete_account.tr(),
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
