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

const sampleMenu = Menu(
  canteen: sampleCanteen,
  categories: [burgers, drinks],
  dishes: sampleDishes,
);
