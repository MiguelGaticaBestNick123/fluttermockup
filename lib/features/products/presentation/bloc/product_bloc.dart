import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductRefreshRequested>(_onRefreshRequested);
    on<ProductStockUpdated>(_onStockUpdated);
    on<ProductCreated>(_onCreated);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
    on<ProductSearchRequested>(_onSearchRequested);
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

  Future<void> _onRefreshRequested(
    ProductRefreshRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts(forceUpdate: true);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onStockUpdated(ProductStockUpdated event, Emitter<ProductState> emit) {
    print('ProductBloc: Received ProductStockUpdated for productId: ${event.productId}, quantity: ${event.quantitySold}');
    if (state is ProductLoaded) {
      final currentProducts = (state as ProductLoaded).products;
      final updatedProducts = currentProducts.map((p) {
        if (p.id == event.productId) {
          print('ProductBloc: Found product ${p.name}, updating stock from ${p.stock} to ${p.stock - event.quantitySold}');
          return Product(
            id: p.id,
            name: p.name,
            description: p.description,
            price: p.price,
            stock: p.stock - event.quantitySold, // Optimistic update
            barcode: p.barcode,
            imageUrl: p.imageUrl,
            createdAt: p.createdAt,
          );
        }
        return p;
      }).toList();
      emit(ProductLoaded(updatedProducts));
    } else {
      print('ProductBloc: State is not ProductLoaded, cannot update stock.');
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

  Future<void> _onSearchRequested(ProductSearchRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts();
      if (event.query.isEmpty) {
        emit(ProductLoaded(products));
      } else {
        final filtered = products.where((p) => 
          p.name.toLowerCase().contains(event.query.toLowerCase())
        ).toList();
        emit(ProductLoaded(filtered));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
