import 'package:json_annotation/json_annotation.dart';

import '../../domain/canteen_repository.dart';

part 'canteen_dtos.g.dart';

/// Backend `CanteenDto`.
@JsonSerializable(createToJson: false)
class CanteenDto {
  const CanteenDto({
    required this.name,
    required this.isAcceptingOrders,
    this.pausedAt,
  });

  factory CanteenDto.fromJson(Map<String, dynamic> json) =>
      _$CanteenDtoFromJson(json);

  final String name;
  final bool isAcceptingOrders;
  final DateTime? pausedAt;

  KitchenSwitch toEntity() => KitchenSwitch(
    accepting: isAcceptingOrders,
    pausedAt: isAcceptingOrders ? null : pausedAt?.toLocal(),
  );
}

@JsonSerializable(createFactory: false)
class SetAcceptingDto {
  const SetAcceptingDto({required this.isAcceptingOrders});

  final bool isAcceptingOrders;

  Map<String, dynamic> toJson() => _$SetAcceptingDtoToJson(this);
}
