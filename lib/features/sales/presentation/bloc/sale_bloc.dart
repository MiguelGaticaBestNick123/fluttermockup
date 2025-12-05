import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRepository saleRepository;

  SaleBloc({required this.saleRepository}) : super(const SaleState()) {
    on<SaleProductAdded>(_onProductAdded);
    on<SaleProductRemoved>(_onProductRemoved);
    on<SaleClientSelected>(_onClientSelected);
    on<SaleProcessed>(_onProcessed);
    on<SaleCleared>(_onCleared);
    on<SaleNumpadPressed>(_onNumpadPressed);
  }

  void _onProductAdded(SaleProductAdded event, Emitter<SaleState> emit) {
    final currentItems = List<SaleItem>.from(state.items);
    final index = currentItems.indexWhere((i) => i.productId == event.product.id);

    if (index >= 0) {
      final existing = currentItems[index];
      currentItems[index] = SaleItem(
        productId: existing.productId,
        quantity: existing.quantity + 1,
        price: existing.price,
        product: existing.product,
      );
    } else {
      currentItems.add(SaleItem(
        productId: event.product.id!,
        quantity: 1,
        price: event.product.price,
        product: event.product,
      ));
    }

    emit(state.copyWith(
      items: currentItems,
      total: _calculateTotal(currentItems),
      status: SaleStatus.initial,
    ));
  }

  void _onProductRemoved(SaleProductRemoved event, Emitter<SaleState> emit) {
    final currentItems = List<SaleItem>.from(state.items);
    final index = currentItems.indexWhere((i) => i.productId == event.product.id);

    if (index >= 0) {
      final existing = currentItems[index];
      if (existing.quantity > 1) {
        currentItems[index] = SaleItem(
          productId: existing.productId,
          quantity: existing.quantity - 1,
          price: existing.price,
          product: existing.product,
        );
      } else {
        currentItems.removeAt(index);
      }
      
      emit(state.copyWith(
        items: currentItems,
        total: _calculateTotal(currentItems),
        status: SaleStatus.initial,
      ));
    }
  }

  void _onClientSelected(SaleClientSelected event, Emitter<SaleState> emit) {
    emit(state.copyWith(selectedClient: event.client));
  }

  void _onCleared(SaleCleared event, Emitter<SaleState> emit) {
    emit(const SaleState());
  }

  void _onNumpadPressed(SaleNumpadPressed event, Emitter<SaleState> emit) {
    if (state.items.isEmpty) return;

    // Modify the quantity of the last added item
    final currentItems = List<SaleItem>.from(state.items);
    final lastIndex = currentItems.length - 1;
    final lastItem = currentItems[lastIndex];

    int newQuantity = lastItem.quantity;
    
    // Simple logic: If key is 'C', clear quantity to 1. If number, append or replace?
    // Let's implement: If previous action was adding product, replace quantity.
    // But for now, let's just say we are building a number.
    // Actually, a common POS pattern is: Type number, then press "Qty" button.
    // But here we have a direct keypad. Let's assume the keypad modifies the quantity directly.
    // If the user types '5', quantity becomes 5. If they type '5' then '0', it becomes 50.
    
    // Wait, the keypad might send 'BACKSPACE' or 'ENTER'.
    // Let's assume the event.value is the key label.
    
    if (event.value == 'C') {
      newQuantity = 1;
    } else if (event.value == '⌫') { // Backspace
       String qStr = newQuantity.toString();
       if (qStr.length > 1) {
         newQuantity = int.parse(qStr.substring(0, qStr.length - 1));
       } else {
         newQuantity = 1;
       }
    } else {
      // It's a number
      // If quantity is 1 (default), replace it. Otherwise append.
      // This is tricky because we don't know if the '1' was user-typed or default.
      // Let's just append for now, but cap it to avoid overflow.
      String qStr = newQuantity.toString();
      if (newQuantity == 1) {
         newQuantity = int.tryParse(event.value) ?? 1;
      } else {
         newQuantity = int.tryParse('$qStr${event.value}') ?? newQuantity;
      }
    }

    currentItems[lastIndex] = SaleItem(
      productId: lastItem.productId,
      quantity: newQuantity,
      price: lastItem.price,
      product: lastItem.product,
    );

    emit(state.copyWith(
      items: currentItems,
      total: _calculateTotal(currentItems),
    ));
  }

  Future<void> _onProcessed(SaleProcessed event, Emitter<SaleState> emit) async {
    if (state.items.isEmpty) return;

    emit(state.copyWith(status: SaleStatus.processing));

    try {
      final sale = Sale(
        userId: 1, // TODO: Get actual user ID from AuthBloc
        clientId: state.selectedClient?.id,
        total: state.total,
        items: state.items,
        date: DateTime.now().toIso8601String(),
      );

      final createdSale = await saleRepository.createSale(sale);
      emit(state.copyWith(
        status: SaleStatus.success, 
        lastCompletedSale: createdSale
      ));
      add(SaleCleared());
    } catch (e) {
      emit(state.copyWith(status: SaleStatus.failure, errorMessage: e.toString()));
    }
  }

  double _calculateTotal(List<SaleItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
