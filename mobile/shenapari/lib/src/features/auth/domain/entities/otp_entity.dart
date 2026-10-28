import 'package:equatable/equatable.dart';

class OtpEntity extends Equatable {
  final String? message;
  final int? expiresInSeconds;
  final String? debugOtp;

  const OtpEntity({this.message, this.expiresInSeconds, this.debugOtp});

  @override
  List<Object?> get props => [message, expiresInSeconds, debugOtp];
}
