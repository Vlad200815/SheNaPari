import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'http_error.g.dart';

@JsonSerializable()
class HttpError extends Equatable {
  @JsonKey(name: "code")
  final int? code;
  @JsonKey(name: "message")
  final String? message;
  final List<HttpDetailsError>? details;

  const HttpError({this.code, this.message, this.details});

  @override
  List<Object?> get props => [code, message, details];

  factory HttpError.fromJson(Map<String, dynamic> json) =>
      _$HttpErrorFromJson(json);

  Map<String, dynamic> toJson() => _$HttpErrorToJson(this);
}

@JsonSerializable()
class HttpDetailsError extends Equatable {
  @JsonKey(name: "@type")
  final String? type;
  final String? additionalProp1;
  final String? additionalProp2;
  final String? additionalProp3;

  const HttpDetailsError({
    this.type,
    this.additionalProp1,
    this.additionalProp2,
    this.additionalProp3,
  });

  factory HttpDetailsError.fromJson(Map<String, dynamic> json) =>
      _$HttpDetailsErrorFromJson(json);

  Map<String, dynamic> toJson() => _$HttpDetailsErrorToJson(this);

  @override
  List<Object?> get props => [
    type,
    additionalProp1,
    additionalProp2,
    additionalProp3,
  ];
}
