import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/storage/app_prefs.dart';

import '../../../core/device/notification_permission.dart';

/// The «Дізнайтесь, коли №7 буде готове» card on «Оплачено»: true = shown.
/// Only while the phone blocks the app's notifications; after the first
/// order, and once more from the third if «Не треба» was tapped; never
/// after a second «Не треба».
class NotificationNudgeCubit extends Cubit<bool> {
  NotificationNudgeCubit(this._permission, this._prefs) : super(false);

  final NotificationPermission _permission;
  final AppPrefs _prefs;

  /// The order whose card may come back after one «Не треба».
  static const secondChanceFrom = 3;

  /// Once per «Оплачено»: counts the order, then decides.
  Future<void> load() async {
    await _prefs.countPaidOrder();
    if (!_permission.canAsk) return;
    if (await _permission.status() == NotificationAccess.granted) return;
    final show = switch (_prefs.notificationNudgesDismissed) {
      0 => true,
      1 => _prefs.paidOrders >= secondChanceFrom,
      _ => false,
    };
    if (!isClosed) emit(show);
  }

  /// «Увімкнути»: the system dialog while it can still be shown, else the
  /// phone's settings for the app.
  Future<void> enable() async {
    if (await _permission.status() == NotificationAccess.blocked) {
      await _permission.openSettings();
      return;
    }
    if (await _permission.request() == NotificationAccess.granted) {
      if (!isClosed) emit(false);
    }
  }

  /// «Не треба».
  Future<void> dismiss() async {
    emit(false);
    await _prefs.dismissNotificationNudge();
  }
}
