import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class Result<T> extends Equatable {
  /// succeeded
  @JsonKey(name: "succeeded")
  final bool? succeeded;

  /// message
  @JsonKey(name: "message")
  final String? message;

  /// data
  @JsonKey(name: "data")
  final T? data;

  /// errors
  @JsonKey(name: "errors")
  final List<String>? errors;

  const Result({
    required this.succeeded,
    required this.message,
    this.data,
    this.errors,
  });

  factory Result.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ResultToJson(this, toJsonT);

  @override
  List<Object?> get props => [succeeded, message, data, errors];
}
