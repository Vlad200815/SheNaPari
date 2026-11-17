import 'package:equatable/equatable.dart';

/// A message under the bell, e.g. «Замовлення №7 готове!».
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.orderId,
  });

  final String id;

  /// The order it is about; tapping the notification opens it.
  final String? orderId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  @override
  List<Object?> get props => [id, orderId, title, body, createdAt, isRead];
}
