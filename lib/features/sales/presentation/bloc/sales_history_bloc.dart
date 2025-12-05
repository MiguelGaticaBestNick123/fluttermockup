import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/sale.dart';
import '../../domain/repositories/sale_repository.dart';

// Events
abstract class SalesHistoryEvent extends Equatable {
  const SalesHistoryEvent();
  @override
  List<Object> get props => [];
}

class SalesHistoryLoadRequested extends SalesHistoryEvent {}

// States
abstract class SalesHistoryState extends Equatable {
  const SalesHistoryState();
  @override
  List<Object> get props => [];
}

class SalesHistoryInitial extends SalesHistoryState {}

class SalesHistoryLoading extends SalesHistoryState {}

class SalesHistoryLoaded extends SalesHistoryState {
  final List<Sale> sales;
  const SalesHistoryLoaded(this.sales);
  @override
  List<Object> get props => [sales];
}

class SalesHistoryError extends SalesHistoryState {
  final String message;
  const SalesHistoryError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class SalesHistoryBloc extends Bloc<SalesHistoryEvent, SalesHistoryState> {
  final SaleRepository saleRepository;

  SalesHistoryBloc({required this.saleRepository}) : super(SalesHistoryInitial()) {
    on<SalesHistoryLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(SalesHistoryLoadRequested event, Emitter<SalesHistoryState> emit) async {
    emit(SalesHistoryLoading());
    try {
      final sales = await saleRepository.getSales();
      emit(SalesHistoryLoaded(sales));
    } catch (e) {
      emit(SalesHistoryError(e.toString()));
    }
  }
}
