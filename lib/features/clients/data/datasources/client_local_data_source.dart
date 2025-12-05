import '../../../../core/database/db_helper.dart';
import '../../../../models/client.dart';

abstract class ClientLocalDataSource {
  Future<List<Client>> getLastClients();
  Future<void> cacheClients(List<Client> clients);
  Future<void> saveClient(Client client);
  Future<void> deleteClient(int id);
}

class ClientLocalDataSourceImpl implements ClientLocalDataSource {
  final DBHelper dbHelper;

  ClientLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<Client>> getLastClients() async {
    return await dbHelper.getClients();
  }

  @override
  Future<void> cacheClients(List<Client> clients) async {
    await dbHelper.clearClients();
    await dbHelper.insertClients(clients);
  }

  @override
  Future<void> saveClient(Client client) async {
    await dbHelper.insertClient(client);
  }

  @override
  Future<void> deleteClient(int id) async {
    await dbHelper.deleteClient(id);
  }
}
