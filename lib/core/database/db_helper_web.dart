import '../../models/product.dart';
import '../../models/client.dart';
import '../../models/sale.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  // In-memory storage for Web testing
  final List<Sale> _webSales = [];
  int _webSaleIdCounter = 1;

  Future<void> insertProducts(List<Product> products) async {}
  Future<List<Product>> getProducts() async => [];
  Future<void> clearProducts() async {}

  Future<void> insertClients(List<Client> clients) async {}
  Future<List<Client>> getClients() async => [];
  Future<void> clearClients() async {}

  Future<void> insertProduct(Product product) async {}
  Future<void> deleteProduct(int id) async {}

  Future<void> insertClient(Client client) async {}
  Future<void> deleteClient(int id) async {}

  Future<int> insertSale(Sale sale) async {
    final id = _webSaleIdCounter++;
    final newSale = sale.copyWith(id: id);
    _webSales.add(newSale);
    print('DBHelper (Web): Inserted sale with ID: $id');
    return id;
  }

  Future<List<Sale>> getSales() async {
    print('DBHelper (Web): Returning ${_webSales.length} sales');
    return List.from(_webSales.reversed);
  }

  Future<void> addToSyncQueue(String action, String endpoint, String payload) async {}
  Future<List<Map<String, dynamic>>> getSyncQueue() async => [];
  Future<void> removeFromSyncQueue(int id) async {}
}
