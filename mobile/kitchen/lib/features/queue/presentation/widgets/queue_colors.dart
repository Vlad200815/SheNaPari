import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/kitchen_order.dart';

/// The colour of each column (the kitchen is always dark): a solid band on
/// the column header, a soft tint on each order's header. The colour is a
/// hint only; an icon and a word always say the same.
class ColumnLook {
  const ColumnLook({
    required this.band,
    required this.onBand,
    required this.tint,
    required this.onTint,
    required this.icon,
  });

  final Color band;
  final Color onBand;
  final Color tint;
  final Color onTint;
  final IconData icon;

  static const late = Color(0xFFF08A73);

  static ColumnLook of(QueueColumn column) => switch (column) {
    QueueColumn.fresh => const ColumnLook(
      band: ColorName.primary400,
      onBand: Color(0xFF2A2000),
      tint: Color(0x29FEBC2F),
      onTint: Color(0xFFFECD4B),
      icon: Icons.add_circle_outline_rounded,
    ),
    QueueColumn.cooking => const ColumnLook(
      band: Color(0xFF6EA2FA),
      onBand: Color(0xFF0B1A33),
      tint: Color(0x296EA2FA),
      onTint: Color(0xFF9DC0FF),
      icon: Icons.soup_kitchen_outlined,
    ),
    QueueColumn.ready => const ColumnLook(
      band: Color(0xFF7BD06B),
      onBand: Color(0xFF0F2A0B),
      tint: Color(0x297BD06B),
      onTint: Color(0xFFA6E39A),
      icon: Icons.check_rounded,
    ),
  };
}

String columnTitle(QueueColumn column) => switch (column) {
  QueueColumn.fresh => LocaleKeys.queue_columns_fresh.tr(),
  QueueColumn.cooking => LocaleKeys.queue_columns_cooking.tr(),
  QueueColumn.ready => LocaleKeys.queue_columns_ready.tr(),
};

String columnStatusWord(QueueColumn column) => switch (column) {
  QueueColumn.fresh => LocaleKeys.queue_status_fresh.tr(),
  QueueColumn.cooking => LocaleKeys.queue_status_cooking.tr(),
  QueueColumn.ready => LocaleKeys.queue_status_ready.tr(),
};

/// `11:40`.
String clock(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
