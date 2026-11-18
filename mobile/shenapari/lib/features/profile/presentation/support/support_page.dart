import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// «Підтримка»: one big button per way to reach us, like ToSim's
/// «Відділ турботи». Each opens the app for it (Telegram, mail); when the
/// phone has none, the contact is copied instead.
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const telegram = 'Vlad_Semeniuk_1';
  static const email = 'supportshenapari@gmail.com';

  /// Telegram's own brand blue, so the button is recognised at a glance.
  static const _telegramBlue = Color(0xFF2AABEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        title: Text(LocaleKeys.support_title.tr(), style: AppText.title()),
      ),
      body: Stack(
        children: [
          const _Decor(),
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.horizontalPadding,
              24,
              AppDimens.horizontalPadding,
              24,
            ),
            children: [
              Text(
                LocaleKeys.support_intro.tr(),
                style: AppText.medium(color: context.colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _ContactButton(
                icon: Icons.telegram,
                label: 'Telegram',
                detail: '@$telegram',
                background: _telegramBlue,
                foreground: ColorName.white,
                onTap: () => _open(
                  context,
                  Uri.parse('https://t.me/$telegram'),
                  copy: '@$telegram',
                ),
              ),
              const SizedBox(height: 14),
              _ContactButton(
                icon: Icons.mail_outline_rounded,
                label: LocaleKeys.support_mail.tr(),
                detail: email,
                background: ColorName.primary400,
                foreground: ColorName.black,
                onTap: () => _open(
                  context,
                  Uri(
                    scheme: 'mailto',
                    path: email,
                    queryParameters: {
                      'subject': LocaleKeys.support_mail_subject.tr(),
                    },
                  ),
                  copy: email,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _open(
    BuildContext context,
    Uri uri, {
    required String copy,
  }) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (opened || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: copy));
    if (!context.mounted) return;
    showInfoSnackBar(
      context,
      LocaleKeys.common_copied_instead.tr(namedArgs: {'text': copy}),
    );
  }
}

/// A big rounded button: brand-coloured, icon, name, the contact itself.
class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.detail,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $detail',
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: foreground, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 19 px bold counts as large text (contrast 3:1).
                        Text(
                          label,
                          style: AppText.title(
                            color: foreground,
                          ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          detail,
                          style: AppText.small(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft yellow circles at the bottom, where ToSim has its illustration.
class _Decor extends StatelessWidget {
  const _Decor();

  @override
  Widget build(BuildContext context) {
    Widget bubble(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorName.primary400.withValues(
          alpha: alpha * context.colors.decorOpacity,
        ),
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(bottom: -80, left: -60, child: bubble(240, 0.18)),
            Positioned(bottom: 90, right: -40, child: bubble(130, 0.14)),
            Positioned(bottom: 40, left: 150, child: bubble(36, 0.3)),
          ],
        ),
      ),
    );
  }
}
