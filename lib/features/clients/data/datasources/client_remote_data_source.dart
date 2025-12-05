import '../../../../models/client.dart';
import '../../../../services/supabase_service.dart';

abstract class ClientRemoteDataSource {
  Future<List<Client>> getClients();
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(int id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final SupabaseService supabaseService;

  ClientRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<List<Client>> getClients() async {
    final data = await supabaseService.getClients();
    return data.map((e) => Client.fromJson(e)).toList();
  }

  @override
  Future<Client> createClient(Client client) async {
    final data = await supabaseService.createClient(client.toMap());
    return Client.fromJson(data);
  }

  @override
  Future<Client> updateClient(Client client) async {
    final data = await supabaseService.updateClient(client.id!, client.toMap());
    return Client.fromJson(data);
  }

  @override
  Future<void> deleteClient(int id) async {
    await supabaseService.deleteClient(id);
  }
}
