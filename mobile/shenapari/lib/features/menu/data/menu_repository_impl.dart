import '../../../core/network/api_call.dart';
import '../../../core/result/result.dart';
import '../domain/entities/break_slot.dart';
import '../domain/entities/canteen.dart';
import '../domain/entities/category.dart';
import '../domain/entities/dish.dart';
import '../domain/menu_repository.dart';
import 'menu_api.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl(this._api, {required String baseUrl}) : _baseUrl = baseUrl;

  final MenuApi _api;

  /// Dish photos come as paths on this server.
  final String _baseUrl;

  @override
  Future<Result<Canteen>> getCanteen() =>
      apiCall(_api.getCanteen, (dto) => dto.toEntity());

  @override
  Future<Result<List<Category>>> getCategories() => apiCall(
    _api.getCategories,
    (dtos) => [for (final dto in dtos) dto.toEntity()],
  );

  @override
  Future<Result<List<Dish>>> getDishes() => apiCall(
    _api.getDishes,
    (dtos) => [for (final dto in dtos) dto.toEntity(baseUrl: _baseUrl)],
  );

  @override
  Future<Result<Dish>> getDish(int id) =>
      apiCall(() => _api.getDish(id), (dto) => dto.toEntity(baseUrl: _baseUrl));

  @override
  Future<Result<BreakSlot?>> getNextBreak() =>
      apiCallNullable(_api.getNextBreak, (dto) => dto.toEntity());
}
