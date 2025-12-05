import 'package:equatable/equatable.dart';
import '../../../../models/client.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object> get props => [];
}

class ClientLoadRequested extends ClientEvent {}

class ClientCreated extends ClientEvent {
  final Client client;
  const ClientCreated(this.client);
  @override
  List<Object> get props => [client];
}

class ClientUpdated extends ClientEvent {
  final Client client;
  const ClientUpdated(this.client);
  @override
  List<Object> get props => [client];
}

class ClientDeleted extends ClientEvent {
  final int id;
  const ClientDeleted(this.id);
  @override
  List<Object> get props => [id];
}
