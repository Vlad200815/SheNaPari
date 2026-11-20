import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

import 'package:shenapari_core/network/api_envelope.dart';
import '../domain/entities/app_notification.dart';

part 'notifications_api.g.dart';

@RestApi()
abstract class NotificationsApi {
  factory NotificationsApi(Dio dio) = _NotificationsApi;

  @GET('/me/notifications')
  Future<ApiEnvelope<List<NotificationDto>>> getAll();

  @POST('/me/notifications/read')
  Future<ApiEnvelope<void>> markAllRead();
}

/// An item of `GET /me/notifications`.
@JsonSerializable(createToJson: false)
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.orderId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  final String id;
  final String? orderId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  AppNotification toEntity() => AppNotification(
    id: id,
    orderId: orderId,
    title: title,
    body: body,
    createdAt: createdAt.toLocal(),
    isRead: isRead,
  );
}
