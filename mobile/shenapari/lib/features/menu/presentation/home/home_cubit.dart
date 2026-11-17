import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/menu.dart';
import '../../domain/usecases/get_menu_use_case.dart';
import 'home_state.dart';
import 'menu_filter.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getMenu) : super(const HomeState());

  final GetMenuUseCase _getMenu;

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
    switch (await _getMenu()) {
      case Ok(value: final menu):
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            menu: menu,
            filter: _keepFilter(state.filter, menu),
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.menu == null ? HomeStatus.failure : HomeStatus.loaded,
            failure: failure,
          ),
        );
    }
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
