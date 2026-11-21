import 'package:shenapari_core/result/result.dart';

/// The kitchen's «we are overloaded» switch. Orders already in the queue
/// are not affected; customers can't place new ones while it's off.
abstract interface class CanteenRepository {
  Future<Result<bool>> isAcceptingOrders();

  /// Pause (`false`) or resume (`true`); the state the server now holds.
  Future<Result<bool>> setAcceptingOrders(bool accepting);
}
