import 'package:flutter/widgets.dart';

import '../../gen/assets.gen.dart';
import '../l10n/l10n.dart';

/// The «ШеНа ПАРІ» wordmark, always as drawn: own colours, own proportions
/// (62 × 40). It is yellow, so it never goes on a yellow surface, and it
/// stays at least 48 wide, or the tongue on «А» stops reading.
///
/// It marks the key moments only: sign-in, a paid order, the pickup code
/// and the «Більше» footer. Not in every app bar.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 62});

  final double width;

  @override
  Widget build(BuildContext context) => Assets.images.icLogo.svg(
    width: width,
    height: width * 40 / 62,
    semanticsLabel: LocaleKeys.app_name.tr(),
  );
}
