import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/gen/colors.gen.dart';
import '../../../menu/presentation/home/break_countdown.dart';
import '../../domain/entities/order.dart';
import '../../../../core/l10n/l10n.dart';

/// Ukrainian names of statuses and the short "when" line, shared by the
/// order list, the order screen and «Мій QR».
extension OrderTexts on Order {
  String get statusLabel => switch (status) {
    OrderStatus.paid => LocaleKeys.orders_status_paid.tr(),
    OrderStatus.accepted => LocaleKeys.orders_status_accepted.tr(),
    OrderStatus.cooking => LocaleKeys.orders_status_cooking.tr(),
    OrderStatus.ready => LocaleKeys.orders_status_ready.tr(),
    OrderStatus.pickedUp => LocaleKeys.orders_status_picked_up.tr(),
    OrderStatus.cancelled => LocaleKeys.orders_status_cancelled.tr(),
    OrderStatus.notPickedUp => LocaleKeys.orders_status_not_picked_up.tr(),
    OrderStatus.unknown => LocaleKeys.orders_status_unknown.tr(),
  };

  /// Background of the status chip; text on it is always dark.
  Color get statusColor => switch (status) {
    OrderStatus.ready => ColorName.primary400,
    OrderStatus.paid ||
    OrderStatus.accepted ||
    OrderStatus.cooking => ColorName.primary100,
    OrderStatus.pickedUp => ColorName.secondary200,
    OrderStatus.cancelled || OrderStatus.notPickedUp => ColorName.redLight,
    OrderStatus.unknown => ColorName.secondary100,
  };

  /// `На перерві о 11:40`, `Готово орієнтовно о 11:52`, `Якнайшвидше`.
  String get whenLabel {
    final ready = estimatedReadyAt;
    if (isActive && ready != null && status != OrderStatus.ready) {
      return LocaleKeys.orders_ready_at.tr(
        namedArgs: {'time': formatClock(ready)},
      );
    }
    final slot = breakSlot;
    if (slot != null) {
      return LocaleKeys.orders_at_break.tr(
        namedArgs: {'time': formatClock(slot.startsAt)},
      );
    }
    return LocaleKeys.orders_asap.tr();
  }

  /// `2 × Чизбургер, Лимонад` for the list card.
  String get itemsSummary => [
    for (final item in items)
      item.quantity > 1 ? '${item.quantity} × ${item.name}' : item.name,
  ].join(', ');
}

/// `17.11, 11:05` — the date the order was placed.
String formatOrderDate(DateTime time) =>
    '${_two(time.day)}.${_two(time.month)}, ${formatClock(time)}';

String _two(int value) => value.toString().padLeft(2, '0');
