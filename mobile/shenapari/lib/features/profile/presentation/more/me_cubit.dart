import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/profile_repository.dart';

/// The signed-in user for the «Більше» header. Null until loaded or when
/// `/me` failed (the header then just greets without a name).
class MeCubit extends Cubit<User?> {
  MeCubit(this._profile) : super(null);

  final ProfileRepository _profile;

  Future<void> load() async {
    if (await _profile.getMe() case Ok(:final value)) emit(value);
  }
}
