import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/usecase.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';
import 'package:shenapari/src/features/menu/domain/repositories/menu_repository.dart';

class FetchProductsUseCase
    extends Functions1<String?, Result<List<ProductEntity>>> {
  final MenuRepository _menuRepository;

  FetchProductsUseCase({required MenuRepository homeRepository})
    : _menuRepository = homeRepository;

  @override
  Future<Result<List<ProductEntity>>> perform(String? category) async {
    return await _menuRepository.fetchProducts(category: category);
  }
}
