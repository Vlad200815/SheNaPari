import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/result/result.dart';

import '../domain/entities/stop_list_dish.dart';
import '../domain/stop_list_repository.dart';
import '../domain/usecases/get_stop_list_use_case.dart';
import 'stop_list_state.dart';

/// «Закінчився борщ» — one switch. It flips at once and goes back if the
/// server says no; the dish leaves the customers' menu right away.
class StopListCubit extends Cubit<StopListState> {
  StopListCubit(this._getStopList, this._repository)
    : super(const StopListState());

  final GetStopListUseCase _getStopList;
  final StopListRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: StopListStatus.loading, failure: null));
    final result = await _getStopList();
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final sections) => state.copyWith(
        status: StopListStatus.loaded,
        sections: sections,
      ),
      Err(:final failure) => state.copyWith(
        status: StopListStatus.failure,
        failure: failure,
      ),
    });
  }

  void search(String query) => emit(state.copyWith(query: query));

  Future<void> toggle(int id) async {
    final dish = state.dishes.where((d) => d.id == id).firstOrNull;
    if (dish == null || state.busy.contains(id)) return;
    await _set(dish, !dish.isAvailable);
  }

  /// «Увімкнути все» in the morning.
  Future<void> enableAll() => Future.wait([
    for (final dish in state.dishes)
      if (!dish.isAvailable && !state.busy.contains(dish.id)) _set(dish, true),
  ]);

  Future<void> _set(StopListDish dish, bool available) async {
    emit(
      state.copyWith(
        sections: _replace(state.sections, dish.withAvailable(available)),
        busy: {...state.busy, dish.id},
        failure: null,
      ),
    );
    final result = await _repository.setAvailable(dish.id, available);
    if (isClosed) return;
    final busy = {...state.busy}..remove(dish.id);
    emit(switch (result) {
      Ok(value: final saved) => state.copyWith(
        sections: _replace(state.sections, saved),
        busy: busy,
      ),
      Err(:final failure) => state.copyWith(
        sections: _replace(state.sections, dish),
        busy: busy,
        failure: failure,
      ),
    });
  }

  static List<StopListSection> _replace(
    List<StopListSection> sections,
    StopListDish dish,
  ) => [
    for (final section in sections)
      StopListSection(
        title: section.title,
        dishes: [for (final d in section.dishes) d.id == dish.id ? dish : d],
      ),
  ];
}
