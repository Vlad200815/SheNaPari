import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';

import '../../menu/menu_samples.dart';

void main() {
  test('adding the same dish twice adds up portions', () {
    final cart = const Cart().add(cheeseburger).add(cheeseburger, quantity: 2);

    expect(cart.items, [const CartItem(dish: cheeseburger, quantity: 3)]);
  });

  test('count and total over all dishes', () {
    final cart = const Cart().add(cheeseburger, quantity: 2).add(lemonade);

    expect(cart.count, 3);
    expect(cart.totalKopecks, 2 * 8500 + 4250);
  });

  test('keeps the order dishes were first added in', () {
    final cart = const Cart().add(lemonade).add(cheeseburger).add(lemonade);

    expect(
      [for (final i in cart.items) i.dish.id],
      [lemonade.id, cheeseburger.id],
    );
  });

  test('never more than 20 portions of one dish', () {
    final cart = const Cart()
        .add(cheeseburger, quantity: 15)
        .add(cheeseburger, quantity: 10);

    expect(cart.quantityOf(cheeseburger.id), Cart.maxQuantity);
  });

  test('setting 0 removes the dish, remove() too', () {
    final cart = const Cart().add(cheeseburger).add(lemonade);

    expect(cart.setQuantity(cheeseburger, 0).quantityOf(cheeseburger.id), 0);
    expect(cart.remove(lemonade.id).items, [
      const CartItem(dish: cheeseburger, quantity: 1),
    ]);
  });

  test('setting 0 for a dish that is not there changes nothing', () {
    expect(const Cart().setQuantity(cheeseburger, 0), const Cart());
  });

  test('fresh dishes from the menu replace the stored copies', () {
    const english = Dish(
      id: 10,
      categoryId: 1,
      name: 'Cheeseburger',
      priceKopecks: 9000,
      weightG: 250,
      kcal: 540,
    );
    final cart = const Cart().add(cheeseburger, quantity: 2).add(lemonade);

    final fresh = cart.withFreshDishes([english]);

    expect(fresh.items, [
      const CartItem(dish: english, quantity: 2),
      CartItem(dish: lemonade.soldOut(), quantity: 1),
    ], reason: 'a dish removed from the menu counts as sold out');
  });

  test('a sold-out dish: greyed in the cart, not in the count or total', () {
    final cart = const Cart()
        .add(cheeseburger, quantity: 2)
        .add(lemonade)
        .withFreshDishes([cheeseburger, lemonade.soldOut()]);

    expect(cart.hasSoldOut, isTrue);
    expect(cart.items, hasLength(2), reason: 'still shown, greyed out');
    expect(cart.count, 2);
    expect(cart.totalKopecks, 2 * 8500);
  });

  test('«Прибрати те, що закінчилось» keeps the rest', () {
    final cart = const Cart()
        .add(cheeseburger)
        .add(lemonade.soldOut())
        .withoutSoldOut();

    expect(cart.items, [const CartItem(dish: cheeseburger, quantity: 1)]);
    expect(cart.hasSoldOut, isFalse);
  });
}
