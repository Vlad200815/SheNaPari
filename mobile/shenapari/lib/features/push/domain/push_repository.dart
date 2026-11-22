import 'package:shenapari_core/result/result.dart';

abstract interface class PushRepository {
  /// Tells the server where this session's pushes go (`PUT /me/push-token`).
  Future<Result<void>> register(String token);
}
