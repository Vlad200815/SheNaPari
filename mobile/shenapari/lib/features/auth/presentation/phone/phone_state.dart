import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';

part 'phone_state.freezed.dart';

enum PhoneStatus { editing, sending, sent, failure }

@freezed
abstract class PhoneState with _$PhoneState {
  const PhoneState._();

  const factory PhoneState({
    /// The 9 digits after `+380`, without spaces.
    @Default('') String digits,
    @Default(PhoneStatus.editing) PhoneStatus status,
    Failure? failure,
  }) = _PhoneState;

  bool get isComplete => digits.length == 9;

  /// The number in the format the server expects.
  String get phone => '+380$digits';
}
