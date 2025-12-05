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
  @override
  Future<Sale> createSale(Sale sale) async {
    try {
      // Try online first
      final remoteSale = await remoteDataSource.createSale(sale);
      // We save it locally as synced=1 (implied by not being in sync queue, or we can add a field)
      // For now, saveSale just saves it. We might need to handle ID conflict if local ID is auto-increment.
      // Ideally, we save the remote ID.
      await localDataSource.saveSale(remoteSale.copyWith(synced: 1));
      return remoteSale;
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
    try {
      // 1. Fetch from remote
      final remoteSales = await remoteDataSource.getSales();
      
      // 2. Cache locally (optional, but good for offline view next time)
      // We might want to clear local sales or merge. For simplicity, we just return remote sales
      // and maybe insert them if they don't exist.
      // Implementing full sync logic here is complex.
      // For now, let's return remote sales directly as requested by user.
      return remoteSales;
    } catch (e) {
      print('SaleRepository: Error fetching remote sales: $e');
      // Fallback to local
      return await localDataSource.getSales();
    }
  }
}
