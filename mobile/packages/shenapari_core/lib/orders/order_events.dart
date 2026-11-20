/// Live order updates from the server (SignalR). The connection is open
/// only while someone listens.
abstract interface class OrderEvents {
  /// The id of an order whose status changed. `null` means "updates may
  /// have been missed" (after a reconnect): reload everything shown.
  Stream<String?> get changes;
}
