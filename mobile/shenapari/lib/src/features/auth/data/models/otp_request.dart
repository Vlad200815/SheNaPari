import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_request.g.dart';

@JsonSerializable()
class OtpRequest extends Equatable {
  /// phone
  @JsonKey(name: "phone")
  final String phone;

  const OtpRequest({required this.phone});

  /// Deserializer...
  factory OtpRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);

  @override
  List<Object?> get props => [phone];
}
