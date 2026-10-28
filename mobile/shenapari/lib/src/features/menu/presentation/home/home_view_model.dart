import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';
import 'package:shenapari/src/features/menu/domain/usecases/fetch_posters_usecase.dart';
import 'package:shenapari/src/features/menu/domain/usecases/fetch_products_usecase.dart';

import 'home_action.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeViewModel extends BaseViewModel<HomeState, HomeEvent, HomeAction> {
  final FetchProductsUseCase _fetchProductsUseCase;
  final FetchPostersUseCase _fetchPostersUseCase;

  List<ProductEntity> _products = [];
  List<PosterEntity> _posters = [];
  bool _isSkeletonLoading = false;

  HomeViewModel({
    required FetchProductsUseCase fetchProductsUseCase,
    required FetchPostersUseCase fetchPostersUseCase,
  }) : _fetchProductsUseCase = fetchProductsUseCase,
       _fetchPostersUseCase = fetchPostersUseCase,
       super(HomeState());

  @override
  Future<void> onViewCreate(
    Emitter<HomeState> emitter,
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) async {
    await _refresh(emitter);
  }

  @override
  Future<void> onViewAction(
    HomeAction action,
    Emitter<HomeState> emitter,
  ) async {
    switch (action) {
      case OnRefreshPulledAction action:
        await _handleOnRefreshPulledAction(action, emitter);

      case OnCategoryChangedAction action:
        await _handleOnCategoryChangedAction(action, emitter);

      case OnNotificationsButtonPressed action:
        await _handleOnNotificationsButtonPressed(action, emitter);

      case OnProductTilePressedAction action:
        await _handleOnProductTilePressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnProductTilePressedAction]
  ///
  Future<void> _handleOnProductTilePressedAction(
    OnProductTilePressedAction action,
    Emitter<HomeState> emitter,
  ) async {
    postEvent(
      OpenProductDetailsPageEvent(id: action.id, section: Config.HOME_SECTION),
      emitter,
    );
  }

  ///
  /// Handle [OnCategoryChangedAction]
  ///
  Future<void> _handleOnCategoryChangedAction(
    OnCategoryChangedAction action,
    Emitter<HomeState> emitter,
  ) async {
    await _fetchProducts(emitter, category: action.category);
  }

  ///
  /// Handle [OnRefreshPulledAction]
  ///
  Future<void> _handleOnRefreshPulledAction(
    OnRefreshPulledAction action,
    Emitter<HomeState> emitter,
  ) async {
    await _refresh(emitter);
  }

  ///
  /// Handle [OnNotificationsButtonPressed]
  ///
  Future<void> _handleOnNotificationsButtonPressed(
    OnNotificationsButtonPressed action,
    Emitter<HomeState> emitter,
  ) async {
    postEvent(OpenNotificationsPageEvent(), emitter);
  }

  /// Refresh
  Future<void> _refresh(Emitter<HomeState> emitter) async {
    _isSkeletonLoading = true;
    _updateState(emitter);
    try {
      debugPrint("Refresh");
      await Future.wait([_fetchPoster(emitter), _fetchProducts(emitter)]);
    } catch (e) {
      setThrowable(e);
    } finally {
      _isSkeletonLoading = false;
      _updateState(emitter);
    }
  }

  /// Fetch Posters
  Future<void> _fetchPoster(Emitter<HomeState> emitter) async {
    Result<List<PosterEntity>> result = await _fetchPostersUseCase.perform();

    if (result.succeeded.orFalse()) {
      _posters = result.data.orEmpty();

      _updateState(emitter);
    } else {
      setThrowable(result.message);
    }
  }

  /// Fetch Products
  Future<void> _fetchProducts(
    Emitter<HomeState> emitter, {
    String? category,
  }) async {
    Result<List<ProductEntity>> result = await _fetchProductsUseCase.perform(
      null,
    );

    if (result.succeeded.orFalse()) {
      _products = result.data.orEmpty();
      _updateState(emitter);

      debugPrint("Products: $_products");
    } else {
      setThrowable(result.message);
    }
  }

  /// Update State
  void _updateState(Emitter<HomeState> emitter) {
    emitter(
      state.copyWith(
        products: _products,
        posters: _posters,
        isSkeletonLoading: _isSkeletonLoading,
      ),
    );
  }
}
