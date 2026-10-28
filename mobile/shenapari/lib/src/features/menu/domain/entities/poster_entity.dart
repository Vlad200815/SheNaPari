import 'package:equatable/equatable.dart';

class PosterEntity extends Equatable {
  final String? posterImage;
  final String? urlLink;

  const PosterEntity({required this.posterImage, required this.urlLink});

  @override
  List<Object?> get props => [posterImage, urlLink];
}
