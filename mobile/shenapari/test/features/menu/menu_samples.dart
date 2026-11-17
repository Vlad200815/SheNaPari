import 'package:shenapari/features/menu/domain/entities/break_slot.dart';
import 'package:shenapari/features/menu/domain/entities/canteen.dart';
import 'package:shenapari/features/menu/domain/entities/category.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/features/menu/domain/entities/menu.dart';

const sampleCanteen = Canteen(name: 'Їдальня №1', isAcceptingOrders: true);

const burgers = Category(id: 1, name: 'Бургери');
const drinks = Category(id: 2, name: 'Напої');

/// Has no dishes in [sampleDishes].
const pastry = Category(id: 3, name: 'Випічка');

const cheeseburger = Dish(
  id: 10,
  categoryId: 1,
  name: 'Чізбургер',
  priceKopecks: 8500,
  weightG: 250,
  kcal: 540,
  isPopular: true,
);

const hamburger = Dish(
  id: 11,
  categoryId: 1,
  name: 'Гамбургер',
  priceKopecks: 7000,
  weightG: 220,
  kcal: 480,
);

const lemonade = Dish(
  id: 20,
  categoryId: 2,
  name: 'Лимонад',
  priceKopecks: 4250,
  weightG: 400,
  kcal: 120,
);

const sampleDishes = [cheeseburger, hamburger, lemonade];

final sampleBreak = BreakSlot(
  id: 1,
  startsAt: DateTime(2026, 11, 17, 11, 40),
  endsAt: DateTime(2026, 11, 17, 12, 0),
);

final sampleMenu = Menu(
  canteen: sampleCanteen,
  categories: const [burgers, drinks],
  dishes: sampleDishes,
  nextBreak: sampleBreak,
);
