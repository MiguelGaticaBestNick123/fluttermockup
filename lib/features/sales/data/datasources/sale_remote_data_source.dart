import '../../../../models/sale.dart';
import '../../../../services/supabase_service.dart';

abstract class SaleRemoteDataSource {
  Future<Sale> createSale(Sale sale);
  Future<List<Sale>> getSales();
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final SupabaseService supabaseService;

  SaleRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<Sale> createSale(Sale sale) async {
    final itemsData = sale.items.map((i) => {
      'product_id': i.productId,
      'quantity': i.quantity,
      'price': i.price,
    }).toList();

    final data = await supabaseService.createSale(
      sale.clientId!, // Assuming clientId is not null for now
      itemsData,
      sale.total,
    );

    // But let's try to map it.
    return Sale.fromJson(data);
  }

  @override
  Future<List<Sale>> getSales() async {
    final data = await supabaseService.getSales();
    return data.map((e) => Sale.fromJson(e)).toList();
  }
}
