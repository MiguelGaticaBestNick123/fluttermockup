import '../../../../core/database/db_helper.dart';
import '../../../../models/product.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getLastProducts();
  Future<void> cacheProducts(List<Product> products);
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DBHelper dbHelper;

  ProductLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<Product>> getLastProducts() async {
    return await dbHelper.getProducts();
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    // await dbHelper.clearProducts(); // No borramos para no perder lo que no se ha sincronizado :v
    await dbHelper.insertProducts(products);
  }

  @override
  Future<void> saveProduct(Product product) async {
    await dbHelper.insertProduct(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
  }
}
