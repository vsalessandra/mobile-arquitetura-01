import '../../domain/entities/product.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
  });

  final int id;
  final String title;
  final double price;
  final String image;
  final String description;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      price: (json['price'] as num).toDouble(),
      image: (json['thumbnail'] as String?) ?? (json['image'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      image: image,
      description: description,
    );
  }
}
