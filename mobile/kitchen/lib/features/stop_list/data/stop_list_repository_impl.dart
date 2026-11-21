import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/entities/stop_list_dish.dart';
import '../domain/stop_list_repository.dart';
import 'dto/stop_list_dtos.dart';
import 'stop_list_api.dart';

class StopListRepositoryImpl implements StopListRepository {
  StopListRepositoryImpl(this._api);

  final StopListApi _api;

  @override
  Future<Result<List<StopListDish>>> getDishes() => apiCall(
    _api.getDishes,
    (dtos) => [for (final dto in dtos) dto.toEntity()],
  );

  @override
  Future<Result<List<DishCategory>>> getCategories() => apiCall(
    _api.getCategories,
    (dtos) => [for (final dto in dtos) dto.toEntity()],
  );

  @override
  Future<Result<StopListDish>> setAvailable(int id, bool available) => apiCall(
    () => _api.setAvailability(id, SetAvailabilityDto(isAvailable: available)),
    (dto) => dto.toEntity(),
  );
}
