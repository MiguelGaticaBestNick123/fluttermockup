import 'package:dio/dio.dart';
import '../../../../models/product.dart';
import '../../../../services/api_service.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiService apiService;

  ProductRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Product>> getProducts() async {
    final response = await apiService.dio.get('/api/products');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products from API');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final response = await apiService.dio.post('/api/products', data: product.toMap());
    return Product.fromJson(response.data);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final response = await apiService.dio.put('/api/products/${product.id}', data: product.toMap());
    return Product.fromJson(response.data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await apiService.dio.delete('/api/products/$id');
  }
}
