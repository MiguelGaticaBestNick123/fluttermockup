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
  Future<List<Product>> getProducts({bool forceUpdate = false}) async {
    try {
      // 1. Get local products first
      final localProducts = await localDataSource.getLastProducts();
      
      // 2. If we have local products and NOT forcing update, return them immediately (Offline-first)
      if (!forceUpdate && localProducts.isNotEmpty) {
        print('ProductRepository: Returning ${localProducts.length} local products');
        return localProducts;
      }

      // 3. If local is empty or forcing update, fetch from remote
      print('ProductRepository: Fetching from remote (forceUpdate: $forceUpdate)...');
      var remoteProducts = await remoteDataSource.getProducts();
      
      // AUTO-MIGRATION: If remote is empty but we have local data, upload local data to Supabase
      if (remoteProducts.isEmpty && localProducts.isNotEmpty) {
        print('ProductRepository: Remote is empty but local has data. Auto-migrating to Supabase...');
        for (var product in localProducts) {
          try {
            // We create the product in Supabase. 
            // Note: IDs might change if we let Supabase generate them, or we can try to preserve them if we enabled identity insert (complex).
            // For simplicity, we let Supabase generate new IDs and we will update local cache later.
            // Ideally we should check if it already exists by barcode or name to avoid duplicates if partial sync happened.
            await remoteDataSource.createProduct(product);
          } catch (e) {
            print('ProductRepository: Failed to migrate product ${product.name}: $e');
          }
        }
        // Fetch again after migration
        remoteProducts = await remoteDataSource.getProducts();
      }

      try {
        await localDataSource.cacheProducts(remoteProducts);
        // CRITICAL FIX: Return the products from the local DB, not the remote ones.
        return await localDataSource.getLastProducts();
      } catch (dbError) {
        print('ProductRepository: CRITICAL DB ERROR in cacheProducts: $dbError');
        // Fallback: If caching fails (e.g. DB error), return remote products so the user sees something.
        return remoteProducts;
      }
    } catch (e) {
      print('ProductRepository: Error fetching/caching products: $e');
      // If remote fails and we have no local data, return empty or rethrow
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
      print('ProductRepository: Error creating remote product: $e');
      // Offline creation: Save locally
      // Note: Since we don't have a sync queue for products yet, this product might be lost on app clear
      // or if we overwrite with remote data. But for now, it allows the user to see the product.
      // We should ideally assign a temporary ID or handle this in localDataSource.
      await localDataSource.saveProduct(product);
      return product;
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
