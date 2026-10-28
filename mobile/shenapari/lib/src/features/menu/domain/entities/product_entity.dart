import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? image;
  final double? rating;
  final String? title;
  final double? price;
  final String? id;

  const ProductEntity({
    required this.image,
    required this.rating,
    required this.title,
    required this.price,
    required this.id,
  });

  @override
  List<Object?> get props => [image, rating, title, price, id];
}
