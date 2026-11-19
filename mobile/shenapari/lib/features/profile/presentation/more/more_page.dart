import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/ui/app_logo.dart';
import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/colors.gen.dart';
import '../../../legal/domain/entities/legal_document.dart';
import '../../domain/entities/user.dart';
import '../widgets/profile_ui.dart';
import 'me_cubit.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../legal/presentation/legal_texts.dart';
import '../../../../core/ui/app_colors.dart';

/// The «Більше» tab: who is signed in, and everything that is not food —
/// help and documents (notifications live behind the bell on the home screen).
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MeCubit>()..load(),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.horizontalPadding,
              20,
              AppDimens.horizontalPadding,
              32,
            ),
            children: [
              BlocBuilder<MeCubit, User?>(
                builder: (context, user) => _Header(user: user),
              ),
              const SizedBox(height: 24),
              MenuCard(
                children: [
                  MenuRow(
                    icon: Icons.help_outline_rounded,
                    tint: ColorName.blue,
                    title: LocaleKeys.more_faq.tr(),
                    onTap: () => context.push(Routes.faq),
                  ),
                  MenuRow(
                    icon: Icons.support_agent_rounded,
                    tint: ColorName.green,
                    title: LocaleKeys.more_support.tr(),
                    subtitle: LocaleKeys.more_support_subtitle.tr(),
                    onTap: () => context.push(Routes.support),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MenuCard(
                children: [
                  MenuRow(
                    icon: Icons.description_outlined,
                    tint: context.colors.iconMuted,
                    title: LegalDocumentType.terms.title,
                    onTap: () =>
                        context.push(Routes.legal(LegalDocumentType.terms)),
                  ),
                  MenuRow(
                    icon: Icons.privacy_tip_outlined,
                    tint: context.colors.iconMuted,
                    title: LegalDocumentType.privacy.title,
                    onTap: () =>
                        context.push(Routes.legal(LegalDocumentType.privacy)),
                  ),
                  MenuRow(
                    icon: Icons.currency_exchange_rounded,
                    tint: context.colors.iconMuted,
                    title: LegalDocumentType.refund.title,
                    onTap: () =>
                        context.push(Routes.legal(LegalDocumentType.refund)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _AppVersion(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The greeting card: brand yellow like the selected filters and the QR
/// button, black text on it, soft white circles as decoration.
class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.name?.trim();
    final phone = user?.phone;
    Widget bubble(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorName.white.withValues(alpha: 0.25),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: ColorName.primary400,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: ExcludeSemantics(child: bubble(150)),
          ),
          Positioned(
            bottom: -40,
            right: 40,
            child: ExcludeSemantics(child: bubble(90)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name == null || name.isEmpty
                      ? LocaleKeys.more_greeting.tr()
                      : LocaleKeys.more_greeting_name.tr(
                          namedArgs: {'name': name},
                        ),
                  style: AppText.heading(
                    color: ColorName.black,
                  ).copyWith(fontSize: 26),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    formatProfilePhone(phone),
                    style: AppText.medium(color: ColorName.black),
                  ),
                ],
                const SizedBox(height: 16),
                Material(
                  color: ColorName.white,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () async {
                      final cubit = context.read<MeCubit>();
                      await context.push(Routes.myProfile);
                      // The name may have changed there.
                      await cubit.load();
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocaleKeys.more_my_profile.tr(),
                              style: AppText.small(
                                color: ColorName.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: ColorName.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo with «версія 1.0.0» under it; just the logo if the version
/// cannot be read.
class _AppVersion extends StatelessWidget {
  const _AppVersion();

  static Future<String?> _version() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _version(),
      builder: (context, snapshot) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(width: 54),
          if (snapshot.data case final version?) ...[
            const SizedBox(height: 6),
            Text(
              LocaleKeys.more_version.tr(namedArgs: {'version': version}),
              style: AppText.small(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
