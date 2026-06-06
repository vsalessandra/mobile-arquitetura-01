import '../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;
  static const _productsUrl = 'https://dummyjson.com/products';

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.get(_productsUrl);

    if (response is! Map<String, dynamic> || response['products'] is! List) {
      throw Exception('Resposta de produtos inválida.');
    }

    final list = response['products'] as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get('$_productsUrl/$id');

    if (response is! Map<String, dynamic>) {
      throw Exception('Resposta de produto inválida.');
    }

    return ProductModel.fromJson(response);
  }
}
