import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// "Привіт, Влад" + "Що будемо їсти?" and the notifications bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    required this.onNotifications,
    this.hasUnread = false,
  });

  final String? firstName;
  final VoidCallback onNotifications;

  /// Shows the orange dot on the bell.
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final name = firstName;
    final greeting = name == null
        ? LocaleKeys.home_greeting.tr()
        : LocaleKeys.home_greeting_name.tr(namedArgs: {'name': name});
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppText.small(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                LocaleKeys.home_question.tr(),
                style: AppText.heading().copyWith(fontSize: 26),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _BellButton(onTap: onNotifications, hasUnread: hasUnread),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap, required this.hasUnread});

  final VoidCallback onTap;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasUnread
          ? LocaleKeys.home_notifications_unread.tr()
          : LocaleKeys.home_notifications.tr(),
      child: Material(
        color: context.colors.surface,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: ColorName.black.withValues(alpha: 0.2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: context.colors.textPrimary,
                  size: 26,
                ),
                if (hasUnread)
                  Positioned(
                    top: 12,
                    right: 13,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: ColorName.primary500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
