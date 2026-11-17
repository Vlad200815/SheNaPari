import 'package:material_ui/material_ui.dart';

import '../../../../gen/colors.gen.dart';
import '../../../menu/presentation/home/break_countdown.dart';
import '../../domain/entities/order.dart';

/// Ukrainian names of statuses and the short "when" line, shared by the
/// order list, the order screen and «Мій QR».
extension OrderTexts on Order {
  String get statusLabel => switch (status) {
    OrderStatus.paid => 'Оплачено',
    OrderStatus.accepted => 'Прийнято',
    OrderStatus.cooking => 'Готується',
    OrderStatus.ready => 'Готово — забирай',
    OrderStatus.pickedUp => 'Видано',
    OrderStatus.cancelled => 'Скасовано',
    OrderStatus.notPickedUp => 'Не забрано',
    OrderStatus.unknown => 'Оновлюється',
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
      return 'Готово орієнтовно о ${formatClock(ready)}';
    }
    final slot = breakSlot;
    if (slot != null) return 'На перерві о ${formatClock(slot.startsAt)}';
    return 'Якнайшвидше';
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
