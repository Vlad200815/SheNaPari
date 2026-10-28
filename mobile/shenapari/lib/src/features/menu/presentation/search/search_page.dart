import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/app/navigation.dart';
import 'package:shenapari/src/core/base/base_page.dart';

import 'search_action.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'search_view_model.dart';

class SearchPage
    extends BasePage<SearchViewModel, SearchState, SearchEvent, SearchAction> {
  @override
  SearchViewModel viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return SearchViewModel();
  }

  @override
  void handleEvent(BuildContext context, SearchEvent event) {
    // TODO: implement handleEvent
  }

  @override
  Widget createView(BuildContext context, SearchState state) {
    return Scaffold(body: Center(child: Text("Search Page")));
  }

  //
  // Navigation
  //
  static String path = "/search";
  static String name = "Search";

  SearchPage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return SearchPage();
    });
  }

  static void open(BuildContext context) {
    return context.go(Uri(path: path).toString());
  }
}
