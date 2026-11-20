import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/entities/kitchen_order.dart';
import '../domain/queue_repository.dart';
import 'dto/staff_order_dtos.dart';
import 'queue_api.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl(this._api);

  final QueueApi _api;

  @override
  Future<Result<List<KitchenOrder>>> getQueue() => apiCall(
    _api.getQueue,
    (dtos) => [for (final dto in dtos) dto.toEntity()],
  );

  @override
  Future<Result<void>> accept(String id, {required int minutes}) async {
    final accepted = await apiCall(
      () => _api.accept(id, AcceptOrderDto(minutes: minutes)),
      (_) {},
    );
    if (accepted is Err) return accepted;
    return setStatus(id, OrderStatus.cooking);
  }

  @override
  Future<Result<void>> setStatus(String id, OrderStatus status) => apiCall(
    () => _api.setStatus(id, UpdateStatusDto(status: orderStatusName(status))),
    (_) {},
  );
}
