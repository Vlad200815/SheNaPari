import '../../../core/result/result.dart';
import 'entities/user.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getMe();

  /// 2–100 characters after trimming, otherwise `profile.invalid_name`.
  Future<Result<User>> updateName(String name);
}
