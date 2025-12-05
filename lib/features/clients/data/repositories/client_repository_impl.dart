import 'package:dio/dio.dart';
import '../../../../models/client.dart';
import '../../data/datasources/client_local_data_source.dart';
import '../../data/datasources/client_remote_data_source.dart';
import '../../domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final ClientLocalDataSource localDataSource;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Client>> getClients() async {
    try {
      final remoteClients = await remoteDataSource.getClients();
      await localDataSource.cacheClients(remoteClients);
      return remoteClients;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        rethrow;
      }
      return await localDataSource.getLastClients();
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    try {
      final remoteClient = await remoteDataSource.createClient(client);
      await localDataSource.saveClient(remoteClient);
      return remoteClient;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Client> updateClient(Client client) async {
    final remoteClient = await remoteDataSource.updateClient(client);
    await localDataSource.saveClient(remoteClient);
    return remoteClient;
  }

  @override
  Future<void> deleteClient(int id) async {
    await remoteDataSource.deleteClient(id);
    await localDataSource.deleteClient(id);
  }
}
