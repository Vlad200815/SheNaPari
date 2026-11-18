import '../../../core/result/result.dart';
import 'entities/user.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getMe();

  /// 2–100 characters after trimming, otherwise `profile.invalid_name`.
  Future<Result<User>> updateName(String name);

  /// Push about own orders on or off (the list under the bell stays).
  Future<Result<User>> setOrderPush({required bool enabled});

  /// Erases the account on the server. Fails with `profile.has_active_order`
  /// (409) while an order is still on the kitchen's board.
  Future<Result<void>> deleteAccount();
}
