import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductCreated>(_onCreated);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreated(ProductCreated event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await productRepository.createProduct(event.product);
      emit(const ProductOperationSuccess('Product created successfully'));
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductOperationFailure(e.toString()));
      add(ProductLoadRequested()); // Reload to show list
    }
  }

  Future<void> _onUpdated(ProductUpdated event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await productRepository.updateProduct(event.product);
      emit(const ProductOperationSuccess('Product updated successfully'));
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductOperationFailure(e.toString()));
      add(ProductLoadRequested());
    }
  }

  Future<void> _onDeleted(ProductDeleted event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await productRepository.deleteProduct(event.id);
      emit(const ProductOperationSuccess('Product deleted successfully'));
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductOperationFailure(e.toString()));
      add(ProductLoadRequested());
    }
  }
}
