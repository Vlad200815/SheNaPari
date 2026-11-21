import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/order.dart';

/// «Погано», «Чудово!»… under the stars; empty for none.
String starsLabel(int stars) => switch (stars) {
  1 => LocaleKeys.rating_s1.tr(),
  2 => LocaleKeys.rating_s2.tr(),
  3 => LocaleKeys.rating_s3.tr(),
  4 => LocaleKeys.rating_s4.tr(),
  5 => LocaleKeys.rating_s5.tr(),
  _ => '',
};

String tagLabel(RatingTag tag) => switch (tag) {
  RatingTag.tasty => LocaleKeys.rating_tags_tasty.tr(),
  RatingTag.fast => LocaleKeys.rating_tags_fast.tr(),
  RatingTag.hot => LocaleKeys.rating_tags_hot.tr(),
  RatingTag.bigPortion => LocaleKeys.rating_tags_big_portion.tr(),
  RatingTag.noQueue => LocaleKeys.rating_tags_no_queue.tr(),
  RatingTag.cold => LocaleKeys.rating_tags_cold.tr(),
  RatingTag.slow => LocaleKeys.rating_tags_slow.tr(),
  RatingTag.smallPortion => LocaleKeys.rating_tags_small_portion.tr(),
  RatingTag.wrongOrder => LocaleKeys.rating_tags_wrong_order.tr(),
  RatingTag.notTasty => LocaleKeys.rating_tags_not_tasty.tr(),
  RatingTag.unknown => '',
};

/// Text in the rating's amber: dark enough on white, the brand yellow on
/// the dark theme.
Color ratingAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? ColorName.primary400
    : const Color(0xFFB26A00);

/// «Бургер з куркою, компот».
String itemsLine(List<String> names) {
  if (names.isEmpty) return '';
  final rest = names.skip(1).map((n) => n.toLowerCase());
  return [names.first, ...rest].join(', ');
}
