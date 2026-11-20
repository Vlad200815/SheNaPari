import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_logo.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import '../../../../gen/assets.gen.dart';

/// The step's picture: the dark variant has a dark grey cloud behind the
/// figure instead of the light one, like the onboarding slides.
Widget themedImage(
  BuildContext context, {
  required AssetGenImage light,
  required AssetGenImage dark,
}) => (Theme.of(context).brightness == Brightness.dark ? dark : light).image(
  fit: BoxFit.contain,
);

/// The common frame of the sign-in screens: step in the app bar, a picture,
/// a title and a subtitle, the [form], and [bottom] pinned to the bottom
/// (it scrolls up with the keyboard instead of being covered by it).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.step,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.bottom,
    this.showLogo = false,
  });

  /// The wordmark above the picture: on the first step, so whoever skipped
  /// the onboarding still sees whose app asks for their number.
  final bool showLogo;

  final String step;
  final Widget image;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          step,
          style: AppText.medium(color: context.colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      if (showLogo) ...[
                        const AppLogo(),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        height: constraints.maxHeight * (showLogo ? 0.24 : 0.3),
                        child: image,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        style: AppText.heading(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        subtitle,
                        style: AppText.regular(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      form,
                      const Spacer(),
                      const SizedBox(height: 8),
                      bottom,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
