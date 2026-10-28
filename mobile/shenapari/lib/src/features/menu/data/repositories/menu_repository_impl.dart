import 'package:shenapari/gen/assets.gen.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/menu/domain/entities/poster_entity.dart';
import 'package:shenapari/src/features/menu/domain/entities/product_entity.dart';
import 'package:shenapari/src/features/menu/domain/repositories/menu_repository.dart';

List<ProductEntity> productsPanini = [
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Panini",
    price: 80,
    id: "test_product_1",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Panini",
    price: 80,
    id: "test_id_2",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Panini",
    price: 80,
    id: "test_product_3",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Panini",
    price: 80,
    id: "test_product_4",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Panini",
    price: 80,
    id: "test_product_5",
  ),
];

List<ProductEntity> productsHotDogs = [
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Hot Dog",
    price: 80,
    id: "test_product_6",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Hot Dog",
    price: 80,
    id: "test_product_7",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Hot Dog",
    price: 80,
    id: "test_product_8",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Hot Dog",
    price: 80,
    id: "test_product_9",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Hot Dog",
    price: 80,
    id: "test_product_10",
  ),
];

List<ProductEntity> productsPizzas = [
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_11",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_12",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_13",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_14",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_15",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_16",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_17",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Pizza",
    price: 80,
    id: "test_product_18",
  ),
];

List<ProductEntity> productsBurgers = [
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_19",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_20",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_21",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_22",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_23",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_24",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_25",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_26",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_27",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_28",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_29",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_30",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_31",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_32",
  ),
  ProductEntity(
    image: "assets/images/home/product.png",
    rating: 4.8,
    title: "Burger",
    price: 80,
    id: "test_product_33",
  ),
];

class MenuRepositoryImpl implements MenuRepository {
  @override
  Future<Result<List<PosterEntity>>> fetchPoster() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    List<PosterEntity> posters = [
      PosterEntity(
        posterImage: Assets.images.test.path,
        urlLink: "https://shenapari.me",
      ),
      PosterEntity(
        posterImage: Assets.images.test.path,
        urlLink: "https://shenapari.me",
      ),
      PosterEntity(
        posterImage: Assets.images.test.path,
        urlLink: "https://shenapari.me",
      ),
      PosterEntity(
        posterImage: Assets.images.test.path,
        urlLink: "https://shenapari.me",
      ),
      PosterEntity(
        posterImage: Assets.images.test.path,
        urlLink: "https://shenapari.me",
      ),
    ];

    return Result<List<PosterEntity>>(
      succeeded: true,
      message: 'success fetched posters',
      data: posters,
    );
  }

  @override
  Future<Result<List<ProductEntity>>> fetchProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 1600));

    List<ProductEntity> products = [];

    switch (category) {
      case "PIZZA":
        products = productsPizzas;
      case "HOT_DOG":
        products = productsHotDogs;
      case "PANINI":
        products = productsPanini;
      default:
        products = productsBurgers;
    }

    return Result<List<ProductEntity>>(
      succeeded: true,
      message: 'success fetched products',
      data: products,
    );
  }
}
