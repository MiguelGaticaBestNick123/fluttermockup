import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository clientRepository;

  ClientBloc({required this.clientRepository}) : super(ClientInitial()) {
    on<ClientLoadRequested>(_onLoadRequested);
    on<ClientCreated>(_onCreated);
    on<ClientUpdated>(_onUpdated);
    on<ClientDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    ClientLoadRequested event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      final clients = await clientRepository.getClients();
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }

  Future<void> _onCreated(ClientCreated event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      await clientRepository.createClient(event.client);
      emit(const ClientOperationSuccess('Client created successfully'));
      add(ClientLoadRequested());
    } catch (e) {
      emit(ClientOperationFailure(e.toString()));
      add(ClientLoadRequested());
    }
  }

  Future<void> _onUpdated(ClientUpdated event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      await clientRepository.updateClient(event.client);
      emit(const ClientOperationSuccess('Client updated successfully'));
      add(ClientLoadRequested());
    } catch (e) {
      emit(ClientOperationFailure(e.toString()));
      add(ClientLoadRequested());
    }
  }

  Future<void> _onDeleted(ClientDeleted event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      await clientRepository.deleteClient(event.id);
      emit(const ClientOperationSuccess('Client deleted successfully'));
      add(ClientLoadRequested());
    } catch (e) {
      emit(ClientOperationFailure(e.toString()));
      add(ClientLoadRequested());
    }
  }
}
