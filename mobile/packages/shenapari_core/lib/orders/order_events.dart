/// Live updates from the server (SignalR). The connection is open only
/// while someone listens to either stream.
abstract interface class OrderEvents {
  /// The id of an order whose status changed. `null` means "updates may
  /// have been missed" (after a reconnect): reload everything shown.
  Stream<String?> get changes;

  /// The kitchen paused (`false`) or resumed (`true`) taking orders.
  Stream<bool> get acceptingOrders;
}
