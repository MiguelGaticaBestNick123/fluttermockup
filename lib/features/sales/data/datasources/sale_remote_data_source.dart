import 'package:dio/dio.dart';
import '../../../../models/sale.dart';
import '../../../../services/api_service.dart';

abstract class SaleRemoteDataSource {
  Future<Sale> createSale(Sale sale);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final ApiService apiService;

  SaleRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Sale> createSale(Sale sale) async {
    final data = {
      "client_id": sale.clientId,
      "items": sale.items.map((i) => i.toMap()).toList(),
    };
    
    final response = await apiService.dio.post('/api/sales', data: data);
    
    if (response.statusCode == 201) {
      return Sale.fromJson(response.data);
    } else {
      throw Exception('Failed to create sale');
    }
  }
}
