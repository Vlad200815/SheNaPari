import 'package:json_annotation/json_annotation.dart';

part 'canteen_dtos.g.dart';

/// Backend `CanteenDto`.
@JsonSerializable(createToJson: false)
class CanteenDto {
  const CanteenDto({required this.name, required this.isAcceptingOrders});

  factory CanteenDto.fromJson(Map<String, dynamic> json) =>
      _$CanteenDtoFromJson(json);

  final String name;
  final bool isAcceptingOrders;
}

@JsonSerializable(createFactory: false)
class SetAcceptingDto {
  const SetAcceptingDto({required this.isAcceptingOrders});

  final bool isAcceptingOrders;

  Map<String, dynamic> toJson() => _$SetAcceptingDtoToJson(this);
}
