import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/presentation/rating/rating_prompt_cubit.dart';

import '../../../../fakes.dart';

void main() {
  late FakeOrdersRepository orders;
  final prompt = RatingPrompt(
    orderId: 'o36',
    number: 36,
    items: const ['Бургер з куркою', 'Компот'],
    pickedUpAt: DateTime(2026, 11, 21, 11, 42),
  );

  setUp(() => orders = FakeOrdersRepository());

  test('shows the order the server asks about', () async {
    orders.prompt = prompt;
    final c = RatingPromptCubit(orders);

    await c.load();

    expect(c.state, prompt);
  });

  test('nothing to ask: no card', () async {
    final c = RatingPromptCubit(orders);

    await c.load();

    expect(c.state, isNull);
  });

  test('«не зараз» hides it at once and tells the server', () async {
    orders.prompt = prompt;
    final c = RatingPromptCubit(orders);
    await c.load();

    await c.dismiss();

    expect(c.state, isNull);
    expect(orders.dismissed, ['o36']);
  });

  test('rated in the sheet: the card goes', () async {
    orders.prompt = prompt;
    final c = RatingPromptCubit(orders);
    await c.load();

    c.rated('o36');

    expect(c.state, isNull);
  });
}
