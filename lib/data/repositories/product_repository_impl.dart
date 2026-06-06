import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    final models = await _remoteDataSource.getProducts();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product> getProductById(int id) async {
    final model = await _remoteDataSource.getProductById(id);
    return model.toEntity();
  }
}
