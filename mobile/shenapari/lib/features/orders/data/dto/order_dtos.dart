import 'package:json_annotation/json_annotation.dart';

import '../../../menu/data/dto/menu_dtos.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_history.dart';

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
    this.rating,
    this.rateUntil,
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

  /// Picked-up orders only, once rated.
  final OrderRatingDto? rating;

  /// Null: it can't be rated (any more).
  final DateTime? rateUntil;

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
    rating: rating?.toEntity(),
    rateUntil: rateUntil?.toLocal(),
  );

  /// `PickedUp` → [OrderStatus.pickedUp]; anything new → `unknown`.
  static OrderStatus parseStatus(String value) => parseOrderStatus(value);

  /// [OrderStatus.pickedUp] → `PickedUp`.
  static String statusName(OrderStatus status) => orderStatusName(status);

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

/// `GET /orders/my/history`
@JsonSerializable(createToJson: false)
class OrderHistoryDto {
  const OrderHistoryDto({
    required this.items,
    required this.hasMore,
    required this.months,
  });

  factory OrderHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryDtoFromJson(json);

  final List<OrderDto> items;
  final bool hasMore;
  final List<OrderMonthDto> months;

  OrderHistoryPage toEntity() => OrderHistoryPage(
    orders: [for (final item in items) item.toEntity()],
    hasMore: hasMore,
    months: [for (final month in months) month.toEntity()],
  );
}

@JsonSerializable(createToJson: false)
class OrderMonthDto {
  const OrderMonthDto({
    required this.year,
    required this.month,
    required this.count,
    required this.spent,
  });

  factory OrderMonthDto.fromJson(Map<String, dynamic> json) =>
      _$OrderMonthDtoFromJson(json);

  final int year;
  final int month;
  final int count;
  final num spent;

  OrderMonth toEntity() => OrderMonth(
    year: year,
    month: month,
    count: count,
    spentKopecks: toKopecks(spent),
  );
}

/// Tag codes as the server sends them: `big_portion` ↔ [RatingTag.bigPortion].
RatingTag parseRatingTag(String code) =>
    RatingTag.values.asNameMap()[_camel(code)] ?? RatingTag.unknown;

String ratingTagCode(RatingTag tag) => tag.name.replaceAllMapped(
  RegExp('[A-Z]'),
  (m) => '_${m[0]!.toLowerCase()}',
);

String _camel(String code) =>
    code.replaceAllMapped(RegExp('_([a-z])'), (m) => m[1]!.toUpperCase());

@JsonSerializable(createToJson: false)
class OrderRatingDto {
  const OrderRatingDto({
    required this.stars,
    this.tags = const [],
    this.comment,
    this.updatedAt,
  });

  factory OrderRatingDto.fromJson(Map<String, dynamic> json) =>
      _$OrderRatingDtoFromJson(json);

  final int stars;
  final List<String> tags;
  final String? comment;
  final DateTime? updatedAt;

  /// Unknown codes (a newer server) are left out rather than shown blank.
  OrderRating toEntity() => OrderRating(
    stars: stars.clamp(1, 5),
    tags: [
      for (final code in tags)
        if (parseRatingTag(code) case final tag when tag != RatingTag.unknown)
          tag,
    ],
    comment: comment,
    updatedAt: updatedAt?.toLocal(),
  );
}

@JsonSerializable(createFactory: false)
class RateOrderDto {
  const RateOrderDto({required this.stars, required this.tags, this.comment});

  final int stars;
  final List<String> tags;
  final String? comment;

  Map<String, dynamic> toJson() => _$RateOrderDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class RatingPromptDto {
  const RatingPromptDto({
    required this.orderId,
    required this.number,
    required this.pickedUpAt,
    this.items = const [],
  });

  factory RatingPromptDto.fromJson(Map<String, dynamic> json) =>
      _$RatingPromptDtoFromJson(json);

  final String orderId;
  final int number;
  final List<String> items;
  final DateTime pickedUpAt;

  RatingPrompt toEntity() => RatingPrompt(
    orderId: orderId,
    number: number,
    items: items,
    pickedUpAt: pickedUpAt.toLocal(),
  );
}
