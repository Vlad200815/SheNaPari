import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/presentation/widgets/order_texts.dart';
import 'package:shenapari/features/orders/presentation/widgets/order_widgets.dart';
import 'package:shenapari_core/ui/app_theme.dart';

Order _order(OrderStatus status, List<(OrderStatus, int)> history) => Order(
  id: 'o9',
  number: 9,
  status: status,
  totalKopecks: 54000,
  createdAt: DateTime(2026, 11, 20, 20, 26),
  items: const [],
  estimatedReadyAt: DateTime(2026, 11, 20, 20, 31),
  history: [
    for (final (s, minute) in history)
      OrderStatusChange(status: s, at: DateTime(2026, 11, 20, 20, minute)),
  ],
);

void main() {
  Future<void> pump(WidgetTester tester, Order order) => tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      home: Scaffold(body: StatusSteps(order: order)),
    ),
  );

  testWidgets('four steps: no «Прийнято», cooking shows the promised time', (
    tester,
  ) async {
    await pump(
      tester,
      _order(OrderStatus.cooking, [
        (OrderStatus.paid, 26),
        (OrderStatus.accepted, 27),
        (OrderStatus.cooking, 27),
      ]),
    );

    expect(find.text('Прийнято'), findsNothing);
    for (final step in ['Оплачено', 'Готується', 'Готово', 'Видано']) {
      expect(find.text(step), findsOneWidget, reason: step);
    }
    expect(find.text('Готово орієнтовно о 20:31'), findsOneWidget);
    expect(find.text('20:27'), findsOneWidget, reason: 'the cooking time');
  });

  testWidgets('only accepted (an older order): already «Готується»', (
    tester,
  ) async {
    final order = _order(OrderStatus.accepted, [
      (OrderStatus.paid, 26),
      (OrderStatus.accepted, 28),
    ]);
    await pump(tester, order);

    expect(find.text('Готово орієнтовно о 20:31'), findsOneWidget);
    expect(find.text('20:28'), findsOneWidget, reason: 'the accept time');
    expect(order.statusLabel, 'Готується');
  });
}
