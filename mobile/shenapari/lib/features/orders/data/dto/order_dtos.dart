import 'package:json_annotation/json_annotation.dart';

import '../../../menu/data/dto/menu_dtos.dart';
import '../../domain/entities/order.dart';

part 'order_dtos.g.dart';

/// `POST /orders`
@JsonSerializable(createFactory: false, explicitToJson: true)
class CreateOrderDto {
  const CreateOrderDto({
    required this.breakSlotId,
    required this.paymentProvider,
    required this.items,
  });

  /// Null = «as soon as possible»; sent explicitly.
  @JsonKey(includeIfNull: true)
  final int? breakSlotId;

  /// PascalCase on the server: `GooglePay`, `ApplePay`.
  final String paymentProvider;
  final List<CreateOrderItemDto> items;

  Map<String, dynamic> toJson() => _$CreateOrderDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class CreateOrderItemDto {
  const CreateOrderItemDto({required this.dishId, required this.quantity});

  final int dishId;
  final int quantity;

  Map<String, dynamic> toJson() => _$CreateOrderItemDtoToJson(this);
}

/// An order as the client sees it (backend `OrderDto`).
@JsonSerializable(createToJson: false)
class OrderDto {
  const OrderDto({
    required this.id,
    required this.number,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    this.breakSlot,
    this.estimatedReadyAt,
    this.readyAt,
    this.history = const [],
    this.pickupToken,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  final String id;
  final int number;
  final String status;
  final num total;
  final DateTime createdAt;
  final List<OrderItemDto> items;
  final BreakSlotDto? breakSlot;
  final DateTime? estimatedReadyAt;
  final DateTime? readyAt;
  final List<OrderStatusChangeDto> history;

  /// Only while the order is ready: what the QR at pickup encodes.
  final String? pickupToken;

  Order toEntity() => Order(
    id: id,
    number: number,
    status: parseStatus(status),
    totalKopecks: toKopecks(total),
    createdAt: createdAt.toLocal(),
    items: [for (final item in items) item.toEntity()],
    breakSlot: breakSlot?.toEntity(),
    estimatedReadyAt: estimatedReadyAt?.toLocal(),
    readyAt: readyAt?.toLocal(),
    history: [for (final change in history) change.toEntity()],
    pickupToken: pickupToken,
  );

  /// `PickedUp` → [OrderStatus.pickedUp]; anything new → `unknown`.
  static OrderStatus parseStatus(String value) =>
      OrderStatus.values.asNameMap()[_camel(value)] ?? OrderStatus.unknown;

  /// [PaymentProvider.googlePay] → `GooglePay`.
  static String providerName(PaymentProvider provider) =>
      provider.name[0].toUpperCase() + provider.name.substring(1);
}

@JsonSerializable(createToJson: false)
class OrderItemDto {
  const OrderItemDto({
    required this.dishId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);

  final int dishId;
  final String name;
  final int quantity;
  final num unitPrice;

  OrderItem toEntity() => OrderItem(
    dishId: dishId,
    name: name,
    quantity: quantity,
    unitPriceKopecks: toKopecks(unitPrice),
  );
}

@JsonSerializable(createToJson: false)
class OrderStatusChangeDto {
  const OrderStatusChangeDto({
    required this.status,
    required this.at,
    this.reason,
  });

  factory OrderStatusChangeDto.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusChangeDtoFromJson(json);

  final String status;
  final DateTime at;
  final String? reason;

  OrderStatusChange toEntity() => OrderStatusChange(
    status: OrderDto.parseStatus(status),
    at: at.toLocal(),
    reason: reason,
  );
}

int toKopecks(num hryvnias) => (hryvnias * 100).round();

String _camel(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
