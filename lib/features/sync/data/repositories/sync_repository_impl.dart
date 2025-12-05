import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/database/db_helper.dart';
import '../../../../services/api_service.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  final DBHelper dbHelper;
  final ApiService apiService;

  SyncRepositoryImpl({required this.dbHelper, required this.apiService});

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

        Response response;
        if (action == 'POST') {
          response = await apiService.dio.post(endpoint, data: payload);
        } else if (action == 'PUT') {
          response = await apiService.dio.put(endpoint, data: payload);
        } else if (action == 'DELETE') {
          response = await apiService.dio.delete(endpoint);
        } else {
          continue;
        }

        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          await dbHelper.removeFromSyncQueue(id);
        }
      } catch (e) {
        print('Sync failed for item ${item['id']}: $e');
        // Keep in queue to retry later
      }
    }
  }
}
