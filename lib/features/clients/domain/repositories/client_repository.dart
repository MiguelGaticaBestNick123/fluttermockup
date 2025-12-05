import '../../../../models/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(int id);
}
