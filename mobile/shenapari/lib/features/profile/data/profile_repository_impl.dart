import '../../../core/network/api_call.dart';
import '../../../core/result/result.dart';
import '../domain/entities/user.dart';
import '../domain/profile_repository.dart';
import 'dto/me_dto.dart';
import 'profile_api.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);

  final ProfileApi _api;

  @override
  Future<Result<User>> getMe() => apiCall(_api.getMe, (dto) => dto.toEntity());

  @override
  Future<Result<User>> updateName(String name) => apiCall(
    () => _api.updateMe(UpdateMeDto(name: name)),
    (dto) => dto.toEntity(),
  );

  @override
  Future<Result<void>> deleteAccount() => apiCallVoid(_api.deleteMe);
}
