import '../../../core/network/api_call.dart';
import '../../../core/result/result.dart';
import '../domain/entities/app_notification.dart';
import '../domain/notifications_repository.dart';
import 'notifications_api.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._api);

  final NotificationsApi _api;

  @override
  Future<Result<List<AppNotification>>> getAll() =>
      apiCall(_api.getAll, (dtos) => [for (final dto in dtos) dto.toEntity()]);

  @override
  Future<Result<void>> markAllRead() => apiCallVoid(_api.markAllRead);
}
