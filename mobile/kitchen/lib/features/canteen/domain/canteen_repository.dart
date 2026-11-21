import 'package:equatable/equatable.dart';
import 'package:shenapari_core/result/result.dart';

/// Is the kitchen taking orders, and since when it is paused.
class KitchenSwitch extends Equatable {
  const KitchenSwitch({required this.accepting, this.pausedAt});

  final bool accepting;

  /// Local time of the pause; null while accepting.
  final DateTime? pausedAt;

  @override
  List<Object?> get props => [accepting, pausedAt];
}

/// The kitchen's «we are overloaded» switch. Orders already in the queue
/// are not affected; customers can't place new ones while it's off.
abstract interface class CanteenRepository {
  Future<Result<KitchenSwitch>> get();

  /// Pause (`false`) or resume (`true`); the state the server now holds.
  Future<Result<KitchenSwitch>> setAcceptingOrders(bool accepting);
}
