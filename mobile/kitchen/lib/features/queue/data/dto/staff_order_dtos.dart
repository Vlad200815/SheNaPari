import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/kitchen_order.dart';

part 'staff_order_dtos.g.dart';

/// An order on the kitchen board (backend `StaffOrderDto`).
@JsonSerializable(createToJson: false)
class StaffOrderDto {
  const StaffOrderDto({
    required this.id,
    required this.number,
    required this.status,
    required this.createdAt,
    required this.items,
    this.customerName,
    this.breakSlot,
    this.estimatedReadyAt,
    this.readyAt,
  });

  factory StaffOrderDto.fromJson(Map<String, dynamic> json) =>
      _$StaffOrderDtoFromJson(json);

  final String id;
  final int number;
  final String status;
  final String? customerName;
  final DateTime createdAt;
  final StaffBreakSlotDto? breakSlot;
  final DateTime? estimatedReadyAt;
  final DateTime? readyAt;
  final List<StaffOrderItemDto> items;

  KitchenOrder toEntity() => KitchenOrder(
    id: id,
    number: number,
    status: parseOrderStatus(status),
    customerName: customerName,
    createdAt: createdAt.toLocal(),
    breakStartsAt: breakSlot?.startsAt.toLocal(),
    estimatedReadyAt: estimatedReadyAt?.toLocal(),
    readyAt: readyAt?.toLocal(),
    items: [
      for (final item in items)
        KitchenOrderItem(name: item.name, quantity: item.quantity),
    ],
  );
}

@JsonSerializable(createToJson: false)
class StaffBreakSlotDto {
  const StaffBreakSlotDto({required this.startsAt});

  factory StaffBreakSlotDto.fromJson(Map<String, dynamic> json) =>
      _$StaffBreakSlotDtoFromJson(json);

  final DateTime startsAt;
}

@JsonSerializable(createToJson: false)
class StaffOrderItemDto {
  const StaffOrderItemDto({required this.name, required this.quantity});

  factory StaffOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$StaffOrderItemDtoFromJson(json);

  final String name;
  final int quantity;
}

/// `POST /staff/orders/{id}/accept`
@JsonSerializable(createFactory: false)
class AcceptOrderDto {
  const AcceptOrderDto({required this.minutes});

  final int minutes;

  Map<String, dynamic> toJson() => _$AcceptOrderDtoToJson(this);
}

/// `PATCH /staff/orders/{id}/status`
@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateStatusDto {
  const UpdateStatusDto({required this.status, this.reason});

  /// PascalCase: `Cooking`, `Ready`, `PickedUp`.
  final String status;
  final String? reason;

  Map<String, dynamic> toJson() => _$UpdateStatusDtoToJson(this);
}
