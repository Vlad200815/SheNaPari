import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';

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
}
