import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/features/cart/data/cart_repository_impl.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';

import '../../menu/menu_samples.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('the cart survives a restart', () async {
    const withPhoto = Dish(
      id: 30,
      categoryId: 1,
      name: 'Круасан',
      description: 'Масляний',
      priceKopecks: 3550,
      weightG: 80,
      kcal: 300,
      imageUrl: 'http://10.0.2.2:5041/images/dishes/30.jpg',
      isPopular: true,
    );
    final cart = const Cart().add(cheeseburger, quantity: 2).add(withPhoto);

    await CartRepositoryImpl(prefs).save(cart);

    expect(CartRepositoryImpl(prefs).load(), cart);
  });

  test('nothing stored: an empty cart', () {
    expect(CartRepositoryImpl(prefs).load(), const Cart());
  });

  test('a broken entry: an empty cart instead of a crash', () async {
    await prefs.setString('cart', '[{"id": "oops"}]');

    expect(CartRepositoryImpl(prefs).load(), const Cart());
  });
}
