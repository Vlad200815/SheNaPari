import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/usecase.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';

import '../repositories/menu_repository.dart';

class FetchPostersUseCase extends Functions<Result<List<PosterEntity>>> {
  final MenuRepository _homeRepository;

  FetchPostersUseCase({required MenuRepository homeRepository})
    : _homeRepository = homeRepository;

  @override
  Future<Result<List<PosterEntity>>> perform() async {
    return await _homeRepository.fetchPoster();
  }
}
