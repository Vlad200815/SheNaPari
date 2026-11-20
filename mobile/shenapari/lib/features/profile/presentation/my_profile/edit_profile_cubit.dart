import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import '../../domain/profile_repository.dart';

part 'edit_profile_cubit.freezed.dart';

enum EditProfileStatus { loading, loadFailure, editing, saving }

@freezed
abstract class EditProfileState with _$EditProfileState {
  const EditProfileState._();

  const factory EditProfileState({
    @Default(EditProfileStatus.loading) EditProfileStatus status,

    /// The name as saved on the server.
    @Default('') String savedName,

    /// What is in the field now.
    @Default('') String name,
    @Default('') String phone,
    Failure? failure,

    /// Bumped after each successful save, for the «Збережено» snack bar.
    @Default(0) int savedCount,
  }) = _EditProfileState;

  String get trimmed => name.trim();

  /// The server takes 2–100 characters (`profile.invalid_name`).
  bool get isNameValid => trimmed.length >= 2 && trimmed.length <= 100;

  bool get isChanged => trimmed != savedName;

  bool get canSave =>
      status == EditProfileStatus.editing && isChanged && isNameValid;
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._profile) : super(const EditProfileState());

  final ProfileRepository _profile;

  Future<void> load() async {
    emit(state.copyWith(status: EditProfileStatus.loading, failure: null));
    switch (await _profile.getMe()) {
      case Ok(value: final user):
        final name = user.name ?? '';
        emit(
          state.copyWith(
            status: EditProfileStatus.editing,
            savedName: name,
            name: name,
            phone: user.phone ?? '',
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: EditProfileStatus.loadFailure,
            failure: failure,
          ),
        );
    }
  }

  void nameChanged(String name) =>
      emit(state.copyWith(name: name, failure: null));

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(status: EditProfileStatus.saving, failure: null));
    switch (await _profile.updateName(state.trimmed)) {
      case Ok(value: final user):
        final name = user.name ?? state.trimmed;
        emit(
          state.copyWith(
            status: EditProfileStatus.editing,
            savedName: name,
            name: name,
            savedCount: state.savedCount + 1,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(status: EditProfileStatus.editing, failure: failure),
        );
    }
  }
}
