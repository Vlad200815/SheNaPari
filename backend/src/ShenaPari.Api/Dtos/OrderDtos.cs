using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Dtos;

public record CreateOrderItemDto(int DishId, int Quantity);

public record CreateOrderDto(int BreakSlotId, List<CreateOrderItemDto> Items);

public record OrderItemDto(int DishId, string Name, int Quantity, decimal UnitPrice);

/// PickupToken is only sent while the order is Ready: that's when the client shows the QR.
public record OrderDto(
    Guid Id,
    int Number,
    OrderStatus Status,
    decimal Total,
    DateTimeOffset CreatedAt,
    BreakSlotDto BreakSlot,
    List<OrderItemDto> Items,
    Guid? PickupToken);

/// What staff see on the order card.
public record StaffOrderDto(
    Guid Id,
    int Number,
    OrderStatus Status,
    decimal Total,
    string? CustomerName,
    BreakSlotDto BreakSlot,
    List<OrderItemDto> Items);

public record UpdateStatusDto(OrderStatus Status);

public record PickupDto(Guid Token);

/// Real-time event payload for SignalR.
public record OrderStatusChangedEvent(Guid OrderId, OrderStatus Status);
