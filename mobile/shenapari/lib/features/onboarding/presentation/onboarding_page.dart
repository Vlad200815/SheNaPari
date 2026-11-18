import 'package:material_ui/material_ui.dart';

import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_theme.dart';
import '../../../gen/assets.gen.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/page_dots.dart';
import '../../../core/l10n/l10n.dart';

/// Three intro slides shown once after install. [onDone] marks them as seen;
/// the router then moves on to sign-in by itself.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

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
              child: Assets.images.icLogo.svg(),
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
                    text: _isLast
                        ? LocaleKeys.onboarding_start.tr()
                        : LocaleKeys.onboarding_next.tr(),
                    onPressed: _isLast ? widget.onDone : _next,
                  ),
                  const SizedBox(height: 10),
                  // Keeps its place on the last slide so the layout does not jump.
                  Visibility.maintain(
                    visible: !_isLast,
                    child: AppButton.outlined(
                      text: LocaleKeys.onboarding_skip.tr(),
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
