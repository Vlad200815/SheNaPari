import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_repository.dart';
import 'session_status.dart';

/// Mirrors [SessionRepository.status] for the widget tree.
class SessionCubit extends Cubit<SessionStatus> {
  SessionCubit(SessionRepository session) : super(session.status) {
    _subscription = session.statusChanges.listen(emit);
  }

  late final StreamSubscription<SessionStatus> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
