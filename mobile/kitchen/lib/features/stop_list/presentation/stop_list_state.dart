import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

import '../domain/entities/stop_list_dish.dart';

part 'stop_list_state.freezed.dart';

enum StopListStatus { loading, loaded, failure }

@freezed
abstract class StopListState with _$StopListState {
  const StopListState._();

  const factory StopListState({
    @Default(StopListStatus.loading) StopListStatus status,
    @Default(<StopListSection>[]) List<StopListSection> sections,
    @Default('') String query,

    /// Dishes with a request in flight.
    @Default(<int>{}) Set<int> busy,
    Failure? failure,
  }) = _StopListState;

  /// The sections with dishes matching [query]; empty ones are left out.
  List<StopListSection> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sections;
    return [
      for (final section in sections)
        if (section.dishes
                .where((d) => d.name.toLowerCase().contains(q))
                .toList()
            case final dishes when dishes.isNotEmpty)
          StopListSection(title: section.title, dishes: dishes),
    ];
  }

  Iterable<StopListDish> get dishes => sections.expand((s) => s.dishes);

  /// «Вимкнено: 3», over the whole menu whatever the search.
  int get offCount => dishes.where((d) => !d.isAvailable).length;
}
