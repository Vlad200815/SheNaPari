import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/canteen_repository.dart';
import 'canteen_api.dart';
import 'dto/canteen_dtos.dart';

class CanteenRepositoryImpl implements CanteenRepository {
  CanteenRepositoryImpl(this._api);

  final CanteenApi _api;

  @override
  Future<Result<bool>> isAcceptingOrders() =>
      apiCall(_api.get, (dto) => dto.isAcceptingOrders);

  @override
  Future<Result<bool>> setAcceptingOrders(bool accepting) => apiCall(
    () => _api.setAccepting(SetAcceptingDto(isAcceptingOrders: accepting)),
    (dto) => dto.isAcceptingOrders,
  );
}
