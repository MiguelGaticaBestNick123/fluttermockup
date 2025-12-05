import '../../../../core/database/db_helper.dart';
import '../../../../models/sale.dart';

abstract class SaleLocalDataSource {
  Future<int> saveSale(Sale sale);
  Future<List<Sale>> getSales();
}

class SaleLocalDataSourceImpl implements SaleLocalDataSource {
  final DBHelper dbHelper;

  SaleLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<int> saveSale(Sale sale) async {
    // We need to implement insertSale in DBHelper
    // For now, we will assume it exists or I will add it shortly
    return await dbHelper.insertSale(sale);
  }

  @override
  Future<List<Sale>> getSales() async {
    return await dbHelper.getSales();
  }
}
