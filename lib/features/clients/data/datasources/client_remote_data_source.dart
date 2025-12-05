import 'package:dio/dio.dart';
import '../../../../models/client.dart';
import '../../../../services/api_service.dart';

abstract class ClientRemoteDataSource {
  Future<List<Client>> getClients();
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(int id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final ApiService apiService;

  ClientRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Client>> getClients() async {
    final response = await apiService.dio.get('/api/clients');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => Client.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load clients from API');
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    final response = await apiService.dio.post('/api/clients', data: client.toMap());
    return Client.fromJson(response.data);
  }

  @override
  Future<Client> updateClient(Client client) async {
    final response = await apiService.dio.put('/api/clients/${client.id}', data: client.toMap());
    return Client.fromJson(response.data);
  }

  @override
  Future<void> deleteClient(int id) async {
    await apiService.dio.delete('/api/clients/$id');
  }
}
