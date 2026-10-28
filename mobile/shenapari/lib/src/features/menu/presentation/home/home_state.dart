import 'package:shenapari/src/core/base/base_view_state.dart';
import 'package:shenapari/src/features/menu/domain/entities/entities.dart';

final class HomeState extends ViewState {
  final List<PosterEntity>? posters;
  final List<ProductEntity>? products;
  final bool? isSkeletonLoading;

  HomeState({this.posters, this.products, this.isSkeletonLoading = false});

  HomeState copyWith({
    List<ProductEntity>? products,
    List<PosterEntity>? posters,
    bool? isSkeletonLoading,
  }) {
    return HomeState(
      posters: posters ?? this.posters,
      products: products ?? this.products,
      isSkeletonLoading: isSkeletonLoading ?? this.isSkeletonLoading,
    );
  }

  @override
  List<Object?> get props => [posters, products, isSkeletonLoading];
}
