import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/orders/order_events.dart';

import 'package:shenapari_core/result/result.dart';
import '../../../profile/domain/entities/user.dart';
import '../../../profile/domain/profile_repository.dart';
import '../../domain/entities/menu.dart';
import '../../domain/usecases/get_menu_use_case.dart';
import 'home_state.dart';
import 'menu_filter.dart';

/// The menu. Stays fresh by itself: reloads when the kitchen switches a
/// dish or the admin edits the menu (SignalR `MenuChanged`), when the
/// kitchen pauses or resumes (`CanteenChanged`, the break card shows it),
/// and after a reconnect, when such events may have been missed.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getMenu, this._profile, this._events)
    : super(const HomeState());

  final GetMenuUseCase _getMenu;
  final ProfileRepository _profile;
  final OrderEvents _events;
  StreamSubscription<void>? _menuChanges;
  StreamSubscription<void>? _reconnects;
  StreamSubscription<void>? _pause;
  Timer? _debounce;

  /// «Увімкнути все» on the kitchen sends an event per dish: one reload.
  static const debounce = Duration(milliseconds: 400);

  /// First load, or "try again" after it failed: shows the skeleton.
  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading, failure: null));
    await _fetch();
    _menuChanges ??= _events.menuChanges.listen((_) => _reloadSoon());
    _pause ??= _events.acceptingOrders.listen((_) => _reloadSoon());
    _reconnects ??= _events.changes
        .where((id) => id == null)
        .listen((_) => _reloadSoon());
  }

  void _reloadSoon() {
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      if (!isClosed) refresh();
    });
  }

  /// Pull-to-refresh: the old menu stays on screen while loading.
  Future<void> refresh() async {
    if (state.menu == null) return load();
    emit(state.copyWith(failure: null));
    await _fetch();
  }

  void selectFilter(MenuFilter filter) => emit(state.copyWith(filter: filter));

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _menuChanges?.cancel();
    await _reconnects?.cancel();
    await _pause?.cancel();
    return super.close();
  }

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
