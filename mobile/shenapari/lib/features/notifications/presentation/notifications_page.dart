import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di.dart';
import '../../../app/router/routes.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_text.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/snack_bars.dart';
import '../../../gen/colors.gen.dart';
import '../../menu/presentation/home/break_countdown.dart';
import '../domain/entities/app_notification.dart';
import 'notifications_cubit.dart';
import '../../../core/l10n/l10n.dart';

/// What the kitchen told the customer about their orders, newest first.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(),
      child: BlocConsumer<NotificationsCubit, NotificationsState>(
        listenWhen: (previous, current) =>
            current.status == NotificationsStatus.loaded &&
            current.failure != null &&
            previous.failure != current.failure,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure!),
        builder: (context, state) => Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: AppBar(
            backgroundColor: ColorName.secondary100,
            title: Text(
              LocaleKeys.notifications_title.tr(),
              style: AppText.title(),
            ),
          ),
          body: switch (state.status) {
            NotificationsStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            NotificationsStatus.failure => _Empty(
              icon: Icons.cloud_off,
              title: state.failure!.text,
              button: LocaleKeys.common_retry.tr(),
              onPressed: context.read<NotificationsCubit>().load,
            ),
            NotificationsStatus.loaded when state.items.isEmpty => _Empty(
              icon: Icons.notifications_none_rounded,
              title: LocaleKeys.notifications_empty_title.tr(),
              subtitle: LocaleKeys.notifications_empty_text.tr(),
            ),
            NotificationsStatus.loaded => RefreshIndicator(
              color: ColorName.primary400,
              onRefresh: context.read<NotificationsCubit>().refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimens.horizontalPadding),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _NotificationTile(item: state.items[index]),
              ),
            ),
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final orderId = item.orderId;
    final isNew = !item.isRead;
    return Material(
      color: isNew ? ColorName.primary100 : ColorName.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: orderId == null
            ? null
            : () => context.push(Routes.order(orderId)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isNew ? ColorName.primary400 : ColorName.secondary100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: ColorName.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppText.small(
                              color: ColorName.typography900,
                              fontWeight: isNew
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isNew)
                          Semantics(
                            label: LocaleKeys.notifications_new.tr(),
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: ColorName.primary500,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: AppText.small(color: ColorName.typography900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatWhen(item.createdAt, DateTime.now()),
                      style: AppText.small().copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `Сьогодні, 11:42`, `Вчора, 18:05`, `14.11, 09:30`.
String formatWhen(DateTime time, DateTime now) {
  final clock = formatClock(time);
  final days = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(time.year, time.month, time.day)).inDays;
  return switch (days) {
    0 => LocaleKeys.notifications_today.tr(namedArgs: {'time': clock}),
    1 => LocaleKeys.notifications_yesterday.tr(namedArgs: {'time': clock}),
    _ =>
      '${time.day.toString().padLeft(2, '0')}.'
          '${time.month.toString().padLeft(2, '0')}, $clock',
  };
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    this.subtitle,
    this.button,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? button;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final button = this.button;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: ColorName.primary100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: ColorName.primary500),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.title(), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: AppText.small(), textAlign: TextAlign.center),
          ],
          if (button != null) ...[
            const SizedBox(height: 24),
            AppButton.primary(text: button, onPressed: onPressed),
          ],
        ],
      ),
    );
  }
}
