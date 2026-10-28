import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta extends Equatable{

  @JsonKey(name: "page")
  final int? page;

  @JsonKey(name: "limit")
  final int? limit;

  @JsonKey(name: "count")
  final int? count;

  @JsonKey(name: "count_formatted")
  final String? countFormatted;

  const Meta(this.page, this.limit, this.count, this.countFormatted);

  @override
  List<Object?> get props => [page, limit,count, countFormatted];

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}