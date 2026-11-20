import 'package:equatable/equatable.dart';

import 'failure.dart';

/// Outcome of an operation that can fail: either [Ok] with a value or
/// [Err] with a [Failure]. Repositories return this instead of throwing.
///
/// Being `sealed`, a `switch` over it must handle both cases.
sealed class Result<T> extends Equatable {
  const Result();

  @override
  bool get stringify => true;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
