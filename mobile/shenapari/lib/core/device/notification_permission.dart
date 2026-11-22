import 'package:permission_handler/permission_handler.dart';

/// Whether the phone lets the app show notifications.
enum NotificationAccess {
  granted,

  /// Not yet or refused once: the system dialog can still be shown.
  denied,

  /// Refused for good (Android: twice): only the phone's settings help.
  blocked,
}

/// The system «allow notifications?» permission. On Android 13+ the dialog
/// can be shown at most twice, so the app asks only when the reason is
/// clear: the onboarding's notifications slide, the card after an order.
abstract interface class NotificationPermission {
  /// False where the app has no pushes to ask for (iPhone for now).
  bool get canAsk;

  Future<NotificationAccess> status();

  /// Shows the system dialog when it still can.
  Future<NotificationAccess> request();

  /// The app's page in the phone's settings.
  Future<void> openSettings();
}

/// Android, through permission_handler (below Android 13 it is granted).
class SystemNotificationPermission implements NotificationPermission {
  @override
  bool get canAsk => true;

  static NotificationAccess _of(PermissionStatus status) => switch (status) {
    PermissionStatus.granted ||
    PermissionStatus.limited => NotificationAccess.granted,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => NotificationAccess.blocked,
    _ => NotificationAccess.denied,
  };

  @override
  Future<NotificationAccess> status() async =>
      _of(await Permission.notification.status);

  @override
  Future<NotificationAccess> request() async =>
      _of(await Permission.notification.request());

  @override
  Future<void> openSettings() => openAppSettings();
}

/// iPhone: no pushes yet (no Apple Developer account), so nothing to ask.
class NoNotificationPermission implements NotificationPermission {
  @override
  bool get canAsk => false;

  @override
  Future<NotificationAccess> status() async => NotificationAccess.granted;

  @override
  Future<NotificationAccess> request() async => NotificationAccess.granted;

  @override
  Future<void> openSettings() async {}
}
