import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import '../../domain/usecases/delete_account_use_case.dart';

part 'delete_account_cubit.freezed.dart';

/// `deleted` keeps the button busy until the router leaves the screen.
enum DeleteAccountStatus { idle, deleting, deleted, failure }

@freezed
abstract class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState({
    @Default(DeleteAccountStatus.idle) DeleteAccountStatus status,
    Failure? failure,
  }) = _DeleteAccountState;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._deleteAccount) : super(const DeleteAccountState());

  final DeleteAccountUseCase _deleteAccount;

  /// Call only after the user confirmed in the dialog.
  Future<void> delete() async {
    if (state.status == DeleteAccountStatus.deleting) return;
    emit(const DeleteAccountState(status: DeleteAccountStatus.deleting));
    switch (await _deleteAccount()) {
      case Ok():
        emit(const DeleteAccountState(status: DeleteAccountStatus.deleted));
      case Err(:final failure):
        emit(
          DeleteAccountState(
            status: DeleteAccountStatus.failure,
            failure: failure,
          ),
        );
    }
  }
}
