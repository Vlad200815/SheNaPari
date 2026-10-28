import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';

abstract interface class MenuRepository {
  Future<Result<List<PosterEntity>>> fetchPoster();
  Future<Result<List<ProductEntity>>> fetchProducts({
    String? category = "BURGER",
  });
}
