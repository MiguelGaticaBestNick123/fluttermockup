import 'dart:convert';
import '../../../../core/database/db_helper.dart';
import '../../../../services/supabase_service.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  final DBHelper dbHelper;
  final SupabaseService supabaseService;

  SyncRepositoryImpl({required this.dbHelper, required this.supabaseService});

  @override
  Future<void> addToQueue(String action, String endpoint, Map<String, dynamic> payload) async {
    await dbHelper.addToSyncQueue(action, endpoint, jsonEncode(payload));
  }

  @override
  Future<void> syncPendingItems() async {
    final pendingItems = await dbHelper.getSyncQueue();
    if (pendingItems.isEmpty) return;

    for (var item in pendingItems) {
      try {
        final id = item['id'] as int;
        final action = item['action'] as String;
        final endpoint = item['endpoint'] as String;
        final payload = jsonDecode(item['payload'] as String);

        if (endpoint.startsWith('/api/products')) {
          await _syncProduct(action, endpoint, payload);
        } else if (endpoint.startsWith('/api/clients')) {
          await _syncClient(action, endpoint, payload);
        } else if (endpoint.startsWith('/api/sales')) {
          await _syncSale(action, endpoint, payload);
        }

        // If successful (no exception thrown), remove from queue
        await dbHelper.removeFromSyncQueue(id);
      } catch (e) {
        print('Sync failed for item ${item['id']}: $e');
        // Keep in queue to retry later
      }
    }
  }

  Future<void> _syncProduct(String action, String endpoint, Map<String, dynamic> payload) async {
    if (action == 'POST') {
      await supabaseService.createProduct(payload);
    } else if (action == 'PUT') {
      final id = int.parse(endpoint.split('/').last);
      await supabaseService.updateProduct(id, payload);
    } else if (action == 'DELETE') {
      final id = int.parse(endpoint.split('/').last);
      await supabaseService.deleteProduct(id);
    }
  }

  Future<void> _syncClient(String action, String endpoint, Map<String, dynamic> payload) async {
    if (action == 'POST') {
      await supabaseService.createClient(payload);
    } else if (action == 'PUT') {
      final id = int.parse(endpoint.split('/').last);
      await supabaseService.updateClient(id, payload);
    } else if (action == 'DELETE') {
      final id = int.parse(endpoint.split('/').last);
      await supabaseService.deleteClient(id);
    }
  }

  Future<void> _syncSale(String action, String endpoint, Map<String, dynamic> payload) async {
    if (action == 'POST') {
      // Payload for sale creation needs to be adapted if necessary
      // payload has 'client_id' and 'items'
      final clientId = payload['client_id'] as int;
      final items = (payload['items'] as List).cast<Map<String, dynamic>>();
      // We need to calculate total if not present, or pass it.
      // The original payload might not have total if it was calculated on backend?
      // Wait, SaleRemoteDataSourceImpl sends: client_id, items.
      // SupabaseService.createSale needs total.
      // We should calculate total from items.
      double total = 0.0;
      for (var i in items) {
        total += (i['price'] as num) * (i['quantity'] as num);
      }
      
      await supabaseService.createSale(clientId, items, total);
    }
  }
}
