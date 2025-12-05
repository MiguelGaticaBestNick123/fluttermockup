import 'package:equatable/equatable.dart';
import '../../../../models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class ProductLoadRequested extends ProductEvent {}

class ProductCreated extends ProductEvent {
  final Product product;
  const ProductCreated(this.product);
  @override
  List<Object> get props => [product];
}

class ProductUpdated extends ProductEvent {
  final Product product;
  const ProductUpdated(this.product);
  @override
  List<Object> get props => [product];
}

class ProductDeleted extends ProductEvent {
  final int id;
  const ProductDeleted(this.id);
  @override
  List<Object> get props => [id];
}
