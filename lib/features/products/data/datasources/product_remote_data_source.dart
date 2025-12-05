import '../../../../models/product.dart';
import '../../../../services/supabase_service.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseService supabaseService;

  ProductRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<List<Product>> getProducts() async {
    final data = await supabaseService.getProducts();
    return data.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    final data = await supabaseService.createProduct(product.toMap());
    return Product.fromJson(data);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final data = await supabaseService.updateProduct(product.id!, product.toMap());
    return Product.fromJson(data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await supabaseService.deleteProduct(id);
  }
}
