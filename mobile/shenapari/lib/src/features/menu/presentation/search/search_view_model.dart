import 'package:shenapari/src/core/base/base_view_model.dart';

import 'search_action.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchViewModel
    extends BaseViewModel<SearchState, SearchEvent, SearchAction> {
  SearchViewModel() : super(SearchState());
}
