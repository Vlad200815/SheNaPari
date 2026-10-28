import 'dart:async';
import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';

import 'app_action.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppViewModel extends BaseViewModel<AppState, AppEvent, AppAction> {
  AppViewModel() : super(AppState());

  // @override
  // Future<void> onViewCreate(
  //   Emitter<AppState> emitter,
  //   Uri uri,
  //   Map<String, String> pathParameters,
  //   Object? extra,
  // ) async {
  //   // _isShowedIntro = await AppPreference.isShowedIntro;
  //   // await _onShowedIntro(emitter);
  // }

  // /// OnShowIntro
  // Future<void> _onShowedIntro(Emitter<AppState> emitter) async {
  //   if (!_isShowedIntro.orFalse()) {
  //     await _updateUi(emitter);
  //     postEvent(OpenOnBoardingPageEvent(), emitter);
  //   } else {
  //     _openHome(emitter);
  //   }
  // }

  ///
  /// Update ui
  ///
  // Future<void> _updateUi(Emitter<AppState> emitter) async {
  //   try {
  //     // logger.log("IsAuth --$_isAuthorized");
  //     emitter(
  //       state.copyWith(
  //         // initialPage: _isAuthorized
  //         //     ? HomePage.route().path
  //         //     : SignInPage.route().path,
  //         isShowedIntro: _isShowedIntro,
  //         // isAuthorized: _isAuthorized,
  //       ),
  //     );
  //   } on Exception catch (error) {
  //     setThrowable(error);
  //   }
  // }

  // StreamSubscription<Uri>? _linkSubscription;
  //
  // Future<void> _initDeepLinks(Emitter<AppState> emitter) async {
  //   try {
  //     final appLinks = AppLinks();
  //     // Handle links
  //     _linkSubscription = appLinks.uriLinkStream.listen((uri) {
  //       debugPrint('onAppLink: $uri');
  //       _openAppLink(uri, emitter);
  //     });
  //   } catch (e) {
  //     setThrowable(e);
  //   }
  // }

  Future<void> _openAppLink(Uri uri, Emitter<AppState> emitter) async {
    logger.log("Received URI: $uri");

    // Перевіряємо, чи це посилання на фільм
    // Шлях зазвичай: /title/tt33270420/
    if (uri.pathSegments.contains('title')) {
      final index = uri.pathSegments.indexOf('title');
      debugPrint("Index of the title: $index");
      debugPrint("Uri path segments: ${uri.pathSegments}");

      debugPrint("Uri is: $uri");
      // Перевіряємо, чи є наступний сегмент (це і буде ID)
      if (uri.pathSegments.length > index + 1) {
        final String movieId = uri.pathSegments[index + 1].trim();
        debugPrint("Navigating to Movie ID: $movieId");

        // postEvent(OpenHomePageEvent(), emitter);
        // postEvent(OpenDetailPageEvent(movieId: movieId), emitter);
      }
    }
  }

  // void _openHome(Emitter<AppState> emitter) {
  //   postEvent(OpenHomePageEvent(), emitter);
  // }
  //
  // @override
  // Future<void> close() {
  //   _linkSubscription?.cancel();
  //   return super.close();
  // }
}
