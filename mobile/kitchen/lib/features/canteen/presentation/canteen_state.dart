import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

part 'canteen_state.freezed.dart';

enum CanteenStatus { loading, loaded, failure }

@freezed
abstract class CanteenState with _$CanteenState {
  const factory CanteenState({
    @Default(CanteenStatus.loading) CanteenStatus status,
    @Default(true) bool accepting,

    /// A pause / resume request is in flight.
    @Default(false) bool busy,
    Failure? failure,
  }) = _CanteenState;
}
