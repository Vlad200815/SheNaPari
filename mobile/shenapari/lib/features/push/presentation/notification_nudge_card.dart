import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../core/l10n/l10n.dart';
import 'notification_nudge_cubit.dart';

/// «Дізнайтесь, коли №7 буде готове»: under the tick on «Оплачено», the
/// moment someone most wants to know. Nothing when [NotificationNudgeCubit]
/// says no.
class NotificationNudgeCard extends StatelessWidget {
  const NotificationNudgeCard({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final shown = context.watch<NotificationNudgeCubit>().state;
    final cubit = context.read<NotificationNudgeCubit>();
    final colors = context.colors;
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !shown
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        size: 20,
                        color: ColorName.primary500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.nudge_title.tr(
                              namedArgs: {'number': '$number'},
                            ),
                            style: AppText.small(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LocaleKeys.nudge_text.tr(),
                            style: AppText.small(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: cubit.enable,
                                style: FilledButton.styleFrom(
                                  backgroundColor: ColorName.primary400,
                                  foregroundColor: ColorName.black,
                                  minimumSize: const Size(44, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  LocaleKeys.nudge_enable.tr(),
                                  style: AppText.small(
                                    color: ColorName.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: cubit.dismiss,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(44, 40),
                                ),
                                child: Text(
                                  LocaleKeys.nudge_dismiss.tr(),
                                  style: AppText.small(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
