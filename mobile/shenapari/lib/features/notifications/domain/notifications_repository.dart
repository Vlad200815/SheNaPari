import 'package:shenapari_core/result/result.dart';
import 'entities/app_notification.dart';

abstract interface class NotificationsRepository {
  /// The latest 50, newest first.
  Future<Result<List<AppNotification>>> getAll();

  /// Called when the list is opened.
  Future<Result<void>> markAllRead();
}
