import 'package:equatable/equatable.dart';

/// A break between classes: orders are picked up during it.
class BreakSlot extends Equatable {
  const BreakSlot({
    required this.id,
    required this.startsAt,
    required this.endsAt,
  });

  final int id;

  /// Local time of the device.
  final DateTime startsAt;
  final DateTime endsAt;

  @override
  List<Object?> get props => [id, startsAt, endsAt];
}
