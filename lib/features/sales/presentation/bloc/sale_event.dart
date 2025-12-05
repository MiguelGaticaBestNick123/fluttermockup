import 'package:equatable/equatable.dart';
import '../../../../models/product.dart';
import '../../../../models/client.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object> get props => [];
}

class SaleProductAdded extends SaleEvent {
  final Product product;
  const SaleProductAdded(this.product);
  @override
  List<Object> get props => [product];
}

class SaleProductRemoved extends SaleEvent {
  final Product product;
  const SaleProductRemoved(this.product);
  @override
  List<Object> get props => [product];
}

class SaleClientSelected extends SaleEvent {
  final Client client;
  const SaleClientSelected(this.client);
  @override
  List<Object> get props => [client];
}

class SaleNumpadPressed extends SaleEvent {
  final String value;
  const SaleNumpadPressed(this.value);
  @override
  List<Object> get props => [value];
}

class SaleProcessed extends SaleEvent {}

class SaleCleared extends SaleEvent {}
