/// Paid → Accepted → Cooking → Ready → PickedUp; Cancelled before cooking,
/// NotPickedUp when nobody came for a ready order. Shared by the customer
/// app and the kitchen.
enum OrderStatus {
  paid,
  accepted,
  cooking,
  ready,
  pickedUp,
  cancelled,
  notPickedUp,
  unknown,
}

/// The API sends PascalCase names (`PickedUp`); anything new → `unknown`.
OrderStatus parseOrderStatus(String value) =>
    OrderStatus.values.asNameMap()[value.isEmpty
        ? value
        : value[0].toLowerCase() + value.substring(1)] ??
    OrderStatus.unknown;

/// [OrderStatus.pickedUp] → `PickedUp`, as the API expects it.
String orderStatusName(OrderStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);
