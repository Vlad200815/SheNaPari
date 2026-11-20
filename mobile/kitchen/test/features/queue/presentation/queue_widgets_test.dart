import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';
import 'package:kitchen/features/queue/presentation/queue_cubit.dart';
import 'package:kitchen/features/queue/presentation/widgets/order_ticket.dart';
import 'package:kitchen/features/queue/presentation/widgets/queue_board.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_theme.dart';

import '../../../fakes.dart';

void main() {
  final now = DateTime(2026, 11, 20, 11, 30);

  Future<void> pumpTicket(WidgetTester tester, KitchenOrder o) =>
      tester.pumpWidget(
        MaterialApp(
          theme: appDarkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderTicket(
                order: o,
                now: now,
                busy: false,
                onAccept: (_) {},
                onReady: () {},
                onHandOver: () {},
              ),
            ),
          ),
        ),
      );

  testWidgets('new, as soon as possible: the ETA choice and «Прийняти»', (
    tester,
  ) async {
    await pumpTicket(tester, order(42, minute: 30));

    expect(find.text('№42'), findsOneWidget);
    expect(find.text('Якнайшвидше'), findsOneWidget);
    expect(find.text('щойно'), findsOneWidget);
    expect(find.text('Прийняти · 10 хв'), findsOneWidget);

    await tester.tap(find.text('15 хв'));
    await tester.pump();
    expect(find.text('Прийняти · 15 хв'), findsOneWidget);
  });

  testWidgets('cooking: «ще 7 хв», then red «+3 хв» once late', (tester) async {
    await pumpTicket(
      tester,
      order(
        40,
        status: OrderStatus.cooking,
        eta: now.add(const Duration(minutes: 7)),
      ),
    );
    expect(find.text('ще 7 хв'), findsOneWidget);

    await pumpTicket(
      tester,
      order(
        38,
        status: OrderStatus.cooking,
        breakAt: DateTime(2026, 11, 20, 11, 40),
        eta: now.subtract(const Duration(minutes: 3)),
      ),
    );
    expect(find.text('+3 хв'), findsOneWidget);
    expect(find.text('Перерва 11:40'), findsOneWidget);
    expect(find.text('Готово'), findsOneWidget);
  });

  testWidgets('ready: the name, and «чекає 24 хв» when it waits too long', (
    tester,
  ) async {
    await pumpTicket(
      tester,
      order(
        35,
        status: OrderStatus.ready,
        readyAt: now.subtract(const Duration(minutes: 24)),
        name: 'Влад',
      ),
    );

    expect(find.text('чекає 24 хв'), findsOneWidget);
    expect(find.text('· Влад'), findsOneWidget);
    expect(find.text('Видати без QR'), findsOneWidget);
  });

  group('board', () {
    late FakeQueueRepository repository;
    late QueueCubit cubit;

    setUp(() {
      repository = FakeQueueRepository([
        order(42, minute: 29),
        order(38, status: OrderStatus.cooking),
        order(36, status: OrderStatus.ready),
      ]);
      cubit = QueueCubit(
        repository,
        FakeOrderEvents(),
        FakeNewOrderAlert(),
        clock: () => now,
      );
    });

    Future<void> pumpBoard(WidgetTester tester, {required bool tablet}) async {
      tester.view.physicalSize = tablet
          ? const Size(1280, 800)
          : const Size(400, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cubit.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: appDarkTheme,
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: QueueBoard(tablet: tablet),
            ),
          ),
        ),
      );
    }

    testWidgets('tablet: three columns side by side', (tester) async {
      await pumpBoard(tester, tablet: true);

      expect(find.text('Нові'), findsOneWidget);
      expect(find.text('Готуються'), findsOneWidget);
      expect(find.text('Готові'), findsOneWidget);
      expect(find.text('№42'), findsOneWidget);
      expect(find.text('№38'), findsOneWidget);
      expect(find.text('№36'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });

    testWidgets('phone: one status at a time, tabs switch it', (tester) async {
      await pumpBoard(tester, tablet: false);
      expect(find.text('№42'), findsOneWidget);
      expect(find.text('№38'), findsNothing);

      await tester.tap(find.text('Готуються · 1'));
      await tester.pumpAndSettle();

      expect(find.text('№38'), findsOneWidget);
      expect(find.text('№42'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });

    testWidgets('a new order: the yellow banner with its number', (
      tester,
    ) async {
      await pumpBoard(tester, tablet: true);

      repository.orders = [...repository.orders, order(44, minute: 30)];
      await cubit.refresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Нове замовлення №44'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text('Нове замовлення №44'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });
  });
}
