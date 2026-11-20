import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shenapari_core/result/result.dart';
import '../../../profile/domain/entities/user.dart';
import '../../../profile/domain/profile_repository.dart';
import '../../domain/entities/menu.dart';
import '../../domain/usecases/get_menu_use_case.dart';
import 'home_state.dart';
import 'menu_filter.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getMenu, this._profile) : super(const HomeState());

  final GetMenuUseCase _getMenu;
  final ProfileRepository _profile;

  /// First load, or "try again" after it failed: shows the skeleton.
  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading, failure: null));
    await _fetch();
  }

  /// Pull-to-refresh: the old menu stays on screen while loading.
  Future<void> refresh() async {
    if (state.menu == null) return load();
    emit(state.copyWith(failure: null));
    await _fetch();
  }

  void selectFilter(MenuFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> _fetch() async {
    final (menuResult, meResult) = await (_getMenu(), _profile.getMe()).wait;
    // The greeting is a nicety: a failed /me must not hide the menu.
    final firstName = switch (meResult) {
      Ok(:final value) => _firstName(value),
      Err() => state.firstName,
    };
    switch (menuResult) {
      case Ok(value: final menu):
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            menu: menu,
            filter: _keepFilter(state.filter, menu),
            firstName: firstName,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.menu == null ? HomeStatus.failure : HomeStatus.loaded,
            failure: failure,
            firstName: firstName,
          ),
        );
    }
  }

  static String? _firstName(User user) {
    final words = user.name?.trim().split(RegExp(r'\s+')) ?? const [];
    return words.isEmpty || words.first.isEmpty ? null : words.first;
  }

  /// After a refresh the selected tab may be gone (its dishes were hidden).
  static MenuFilter _keepFilter(MenuFilter filter, Menu menu) {
    final stillThere = switch (filter) {
      AllDishes() => true,
      PopularDishes() => menu.hasPopular,
      CategoryDishes(:final categoryId) => menu.categories.any(
        (category) => category.id == categoryId,
      ),
    };
    return stillThere ? filter : const AllDishes();
  }
}
