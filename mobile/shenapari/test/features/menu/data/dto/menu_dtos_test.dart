import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/menu/data/dto/menu_dtos.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';

const _baseUrl = 'http://10.0.2.2:5041';

Map<String, dynamic> _dishJson({Object price = 85, String? imageUrl}) => {
  'id': 7,
  'categoryId': 2,
  'name': 'Чізбургер',
  'description': 'Яловичина, сир чедер',
  'price': price,
  'weightG': 250,
  'kcal': 540,
  'imageUrl': imageUrl,
  'isPopular': true,
};

void main() {
  test('reads a dish from GET /dishes', () {
    final dish = DishDto.fromJson(
      _dishJson(imageUrl: '/images/dishes/7-ab12.jpg'),
    ).toEntity(baseUrl: _baseUrl);

    expect(
      dish,
      const Dish(
        id: 7,
        categoryId: 2,
        name: 'Чізбургер',
        description: 'Яловичина, сир чедер',
        priceKopecks: 8500,
        weightG: 250,
        kcal: 540,
        imageUrl: 'http://10.0.2.2:5041/images/dishes/7-ab12.jpg',
        isPopular: true,
      ),
    );
  });

  test('a fractional price becomes exact kopecks', () {
    int kopecks(Object price) => DishDto.fromJson(
      _dishJson(price: price),
    ).toEntity(baseUrl: _baseUrl).priceKopecks;

    expect(kopecks(42.5), 4250);
    expect(kopecks(19.99), 1999);
    expect(kopecks(0.1 + 0.2), 30);
  });

  test('nutrition, spiciness and the vegan mark', () {
    final dish = DishDto.fromJson({
      ..._dishJson(),
      'proteinG': 16,
      'fatG': 20,
      'carbsG': 58,
      'spicyLevel': 2,
      'isVegan': true,
    }).toEntity(baseUrl: _baseUrl);

    expect((dish.proteinG, dish.fatG, dish.carbsG), (16, 20, 58));
    expect(dish.hasMacros, isTrue);
    expect(dish.spicyLevel, 2);
    expect(dish.isVegan, isTrue);
  });

  test('an older server: no macros, not spicy, not vegan', () {
    final dish = DishDto.fromJson(_dishJson()).toEntity(baseUrl: _baseUrl);

    expect(dish.hasMacros, isFalse);
    expect(dish.spicyLevel, 0);
    expect(dish.isVegan, isFalse);
    expect(dish.isAvailable, isTrue);
  });

  test('a dish on the stop list comes as sold out', () {
    final dish = DishDto.fromJson({
      ..._dishJson(),
      'isAvailable': false,
    }).toEntity(baseUrl: _baseUrl);

    expect(dish.isAvailable, isFalse);
  });

  test('a dish without a photo keeps imageUrl null', () {
    final dish = DishDto.fromJson(_dishJson()).toEntity(baseUrl: _baseUrl);

    expect(dish.imageUrl, isNull);
  });

  test('an absolute imageUrl is left as is', () {
    final dish = DishDto.fromJson(
      _dishJson(imageUrl: 'https://cdn.example.com/a.jpg'),
    ).toEntity(baseUrl: _baseUrl);

    expect(dish.imageUrl, 'https://cdn.example.com/a.jpg');
  });

  test('reads the canteen and a category', () {
    final canteen = CanteenDto.fromJson({
      'name': 'Їдальня №1',
      'isAcceptingOrders': false,
    }).toEntity();
    final category = CategoryDto.fromJson({
      'id': 2,
      'name': 'Бургери',
    }).toEntity();

    expect(canteen.name, 'Їдальня №1');
    expect(canteen.isAcceptingOrders, isFalse);
    expect(category.id, 2);
    expect(category.name, 'Бургери');
  });

  test('a break comes in UTC and becomes local time', () {
    final slot = BreakSlotDto.fromJson({
      'id': 3,
      'startsAt': '2026-11-17T09:40:00+00:00',
      'endsAt': '2026-11-17T10:00:00+00:00',
    }).toEntity();

    expect(slot.startsAt.isUtc, isFalse);
    expect(slot.startsAt, DateTime.utc(2026, 11, 17, 9, 40).toLocal());
  });
}
