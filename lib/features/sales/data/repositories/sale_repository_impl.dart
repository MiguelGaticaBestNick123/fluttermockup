import '../../../../models/sale.dart';
import '../../data/datasources/sale_local_data_source.dart';
import '../../data/datasources/sale_remote_data_source.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../sync/domain/repositories/sync_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDataSource remoteDataSource;
  final SaleLocalDataSource localDataSource;
  final SyncRepository syncRepository;

  SaleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncRepository,
  });

  @override
  @override
  Future<Sale> createSale(Sale sale) async {
    try {
      // Try online first
      // final remoteSale = await remoteDataSource.createSale(sale);
      // await localDataSource.saveSale(remoteSale);
      // return remoteSale;
      throw Exception('Offline mode forced for testing');
    } catch (e) {
      print('SaleRepository: Error creating remote sale (or offline mode): $e');
      // If offline, save to local DB with synced=0
      final offlineSale = Sale(
        userId: sale.userId,
        clientId: sale.clientId,
        total: sale.total,
        date: sale.date,
        items: sale.items,
        synced: 0,
      );
      
      try {
        final id = await localDataSource.saveSale(offlineSale);
        print('SaleRepository: Sale saved locally with ID: $id');
        
        // Add to Sync Queue
        await syncRepository.addToQueue(
          'POST', 
          '/api/sales', 
          offlineSale.toMap()..remove('id')..remove('synced') // Send clean data
        );
        
        return offlineSale.copyWith(id: id);
      } catch (dbError) {
        print('SaleRepository: Critical DB Error: $dbError');
        rethrow;
      }
    }
  }

  @override
  Future<List<Sale>> getSales() async {
    // For now, we only fetch from local DB for offline-first experience
    // In a real app, we might want to fetch from remote and sync
    return await localDataSource.getSales();
  }
}
