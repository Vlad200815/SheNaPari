import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/session_repository.dart';

import '../../domain/staff_auth_repository.dart';
import 'login_state.dart';

/// The staff sign-in. On success it only stores the session: the router
/// sees the status change and opens the queue by itself.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth, this._session) : super(const LoginState());

  final StaffAuthRepository _auth;
  final SessionRepository _session;

  void emailChanged(String email) => emit(
    state.copyWith(email: email, status: LoginStatus.editing, failure: null),
  );

  void passwordChanged(String password) => emit(
    state.copyWith(
      password: password,
      status: LoginStatus.editing,
      failure: null,
    ),
  );

  Future<void> submit() async {
    if (!state.canSubmit || state.status == LoginStatus.sending) return;
    emit(state.copyWith(status: LoginStatus.sending, failure: null));
    switch (await _auth.login(
      email: state.email.trim(),
      password: state.password,
    )) {
      case Ok(value: final tokens):
        await _session.save(tokens, isNewUser: false);
      case Err(:final failure):
        emit(state.copyWith(status: LoginStatus.failure, failure: failure));
    }
  }
}
