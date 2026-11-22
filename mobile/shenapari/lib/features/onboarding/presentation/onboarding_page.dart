import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_button.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari_core/ui/app_logo.dart';
import '../../../gen/assets.gen.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/page_dots.dart';
import '../../../core/device/notification_permission.dart';
import '../../../core/l10n/l10n.dart';

/// Three intro slides shown once after install. [onDone] marks them as seen;
/// the router then moves on to sign-in by itself.
///
/// The last slide is about live notifications, so that is where the system
/// «allow notifications?» dialog comes, from «Увімкнути сповіщення» — the
/// moment the reason is on screen. «Пізніше» asks nothing and keeps the
/// second (and last) system ask for the card after the first order.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone, this.notifications});

  final VoidCallback onDone;

  /// Null, or a phone without pushes to ask for: a plain «Почати».
  final NotificationPermission? notifications;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static List<OnboardingSlide> get _slides => [
    OnboardingSlide(
      image: Assets.images.onboarding.welcome,
      title: LocaleKeys.onboarding_welcome_title.tr(),
      text: LocaleKeys.app_name.tr(),
      highlightText: true,
    ),
    OnboardingSlide(
      image: Assets.images.onboarding.orderInSeconds,
      title: LocaleKeys.onboarding_order_title.tr(),
      text: LocaleKeys.onboarding_order_text.tr(),
    ),
    OnboardingSlide(
      image: Assets.images.onboarding.realtimeNotifications,
      title: LocaleKeys.onboarding_calm_title.tr(),
      text: LocaleKeys.onboarding_calm_text.tr(),
    ),
  ];

  bool get _isLast => _page == _slides.length - 1;

  bool get _asks => widget.notifications?.canAsk ?? false;

  Future<void> _enableNotifications() async {
    await widget.notifications?.request();
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const AppLogo(),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: _slides,
              ),
            ),
            const SizedBox(height: 20),
            PageDots(count: _slides.length, selected: _page),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalPadding,
              ),
              child: Column(
                children: [
                  AppButton.primary(
                    text: switch ((_isLast, _asks)) {
                      (true, true) =>
                        LocaleKeys.onboarding_enable_notifications.tr(),
                      (true, false) => LocaleKeys.onboarding_start.tr(),
                      _ => LocaleKeys.onboarding_next.tr(),
                    },
                    onPressed: switch ((_isLast, _asks)) {
                      (true, true) => _enableNotifications,
                      (true, false) => widget.onDone,
                      _ => _next,
                    },
                  ),
                  const SizedBox(height: 10),
                  // Keeps its place on the last slide so the layout does not jump.
                  Visibility.maintain(
                    visible: !_isLast || _asks,
                    child: AppButton.outlined(
                      text: _isLast
                          ? LocaleKeys.onboarding_later.tr()
                          : LocaleKeys.onboarding_skip.tr(),
                      onPressed: widget.onDone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
