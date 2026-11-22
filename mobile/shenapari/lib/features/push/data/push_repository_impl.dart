import 'package:shenapari_core/network/api_call.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/push_repository.dart';
import 'push_api.dart';

class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl(this._api);

  final PushApi _api;

  @override
  Future<Result<void>> register(String token) =>
      apiCallVoid(() => _api.setToken(PushTokenDto(token: token)));
}
