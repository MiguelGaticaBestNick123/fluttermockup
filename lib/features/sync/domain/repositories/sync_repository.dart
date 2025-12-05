abstract class SyncRepository {
  Future<void> addToQueue(String action, String endpoint, Map<String, dynamic> payload);
  Future<void> syncPendingItems();
}
