import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/auth_repository.dart';
import 'phone_state.dart';

class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._auth) : super(const PhoneState());

  final AuthRepository _auth;

  /// [input] is what the field shows (`67 123 45 67`); spaces are dropped.
  void phoneChanged(String input) => emit(
    state.copyWith(
      digits: input.replaceAll(RegExp(r'\D'), ''),
      status: PhoneStatus.editing,
      failure: null,
    ),
  );

  Future<void> submit() async {
    if (!state.isComplete || state.status == PhoneStatus.sending) return;
    emit(state.copyWith(status: PhoneStatus.sending, failure: null));

    switch (await _auth.requestCode(phone: state.phone)) {
      case Ok():
      // A code was sent less than a minute ago (the user came back from the
      // code screen). It is still valid, so go on and let them enter it.
      case Err(failure: ServerFailure(code: 'auth.too_many_requests')):
        emit(state.copyWith(status: PhoneStatus.sent));
      case Err(:final failure):
        emit(state.copyWith(status: PhoneStatus.failure, failure: failure));
    }
  }
}
