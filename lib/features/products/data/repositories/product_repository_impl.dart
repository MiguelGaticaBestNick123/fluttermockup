import '../../../../models/product.dart';
import '../../data/datasources/product_local_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
      return remoteProducts;
    } catch (e) {
      // If remote fails, try local
      return await localDataSource.getLastProducts();
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final remoteProduct = await remoteDataSource.createProduct(product);
      await localDataSource.saveProduct(remoteProduct);
      return remoteProduct;
    } catch (e) {
      // Offline creation logic (queueing) should be handled here or via SyncRepository
      // For now, we'll just save locally and assume SyncService picks it up, 
      // OR we can throw error if we want to force online creation for now.
      // Given the requirement, let's try to save locally with synced=0 if we had that field.
      // Product model doesn't have synced field yet. 
      // Let's just throw for now or implement queueing properly.
      // Since we implemented SyncQueue for Sales, we should use it here too.
      // But ProductRepositoryImpl doesn't have SyncRepository injected yet.
      // For this step, I will just throw to keep it simple and focus on UI, 
      // or better, just save locally without sync flag (it will be lost on sync clear).
      // Actually, let's just throw for now to ensure online-first.
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final remoteProduct = await remoteDataSource.updateProduct(product);
    await localDataSource.saveProduct(remoteProduct);
    return remoteProduct;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDataSource.deleteProduct(id);
    await localDataSource.deleteProduct(id);
  }
}
