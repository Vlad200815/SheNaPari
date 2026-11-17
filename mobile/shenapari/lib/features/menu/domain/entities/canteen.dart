import 'package:equatable/equatable.dart';

class Canteen extends Equatable {
  const Canteen({required this.name, required this.isAcceptingOrders});

  final String name;

  /// False while the kitchen has paused orders: the menu can still be viewed.
  final bool isAcceptingOrders;

  @override
  List<Object?> get props => [name, isAcceptingOrders];
}
