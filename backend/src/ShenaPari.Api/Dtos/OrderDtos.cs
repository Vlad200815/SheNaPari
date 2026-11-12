using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Dtos;

public record CreateOrderItemDto(int DishId, int Quantity);

/// BreakSlotId = null means "as soon as possible".
public record CreateOrderDto(int? BreakSlotId, PaymentProvider? PaymentProvider, List<CreateOrderItemDto> Items);

public record OrderItemDto(int DishId, string Name, int Quantity, decimal UnitPrice);

public record OrderStatusChangeDto(OrderStatus Status, DateTimeOffset At, string? Reason);

/// PickupToken is only sent while the order is Ready: that's when the client shows the QR.
public record OrderDto(
    Guid Id,
    int Number,
    OrderStatus Status,
    decimal Total,
    DateTimeOffset CreatedAt,
    BreakSlotDto? BreakSlot,
    DateTimeOffset? EstimatedReadyAt,
    DateTimeOffset? ReadyAt,
    PaymentProvider PaymentProvider,
    List<OrderItemDto> Items,
    List<OrderStatusChangeDto> History,
    Guid? PickupToken);

/// What staff see on the order card.
public record StaffOrderDto(
    Guid Id,
    int Number,
    OrderStatus Status,
    decimal Total,
    string? CustomerName,
    DateTimeOffset CreatedAt,
    BreakSlotDto? BreakSlot,
    DateTimeOffset? EstimatedReadyAt,
    DateTimeOffset? ReadyAt,
    List<OrderItemDto> Items,
    List<OrderStatusChangeDto> History);

/// Minutes until ready: 5, 10, 15 or 20.
public record AcceptOrderDto(int Minutes);

public record UpdateStatusDto(OrderStatus Status, string? Reason = null);

public record PickupDto(Guid Token);

/// Real-time event payload for SignalR.
public record OrderStatusChangedEvent(Guid OrderId, int Number, OrderStatus Status, DateTimeOffset? EstimatedReadyAt);

public record CanteenDto(string Name, bool IsAcceptingOrders);

public record SetAcceptingDto(bool IsAcceptingOrders);

public record SetAvailabilityDto(bool IsAvailable);
