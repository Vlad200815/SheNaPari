import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/complete_registration.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._completeRegistration)
    : super(const RegistrationState());

  final CompleteRegistration _completeRegistration;

  void nameChanged(String name) => emit(
    state.copyWith(
      name: name,
      status: RegistrationStatus.editing,
      failure: null,
    ),
  );

  Future<void> submit() async {
    if (!state.canSubmit || state.isBusy) return;
    emit(state.copyWith(status: RegistrationStatus.saving, failure: null));

    switch (await _completeRegistration(name: state.name)) {
      case Ok():
        emit(state.copyWith(status: RegistrationStatus.saved));
      case Err(:final failure):
        emit(
          state.copyWith(status: RegistrationStatus.failure, failure: failure),
        );
    }
  }
}
