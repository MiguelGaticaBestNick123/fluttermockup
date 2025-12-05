import '../../../../models/sale.dart';

abstract class SaleRepository {
  Future<Sale> createSale(Sale sale);
  Future<List<Sale>> getSales();
}
