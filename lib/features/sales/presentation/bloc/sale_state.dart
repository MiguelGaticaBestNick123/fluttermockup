import 'package:equatable/equatable.dart';
import '../../../../models/product.dart';
import '../../../../models/client.dart';
import '../../../../models/sale.dart';

enum SaleStatus { initial, processing, success, failure }

class SaleState extends Equatable {
  final List<SaleItem> items;
  final Client? selectedClient;
  final double total;
  final SaleStatus status;
  final String? errorMessage;
  final Sale? lastCompletedSale;

  const SaleState({
    this.items = const [],
    this.selectedClient,
    this.total = 0.0,
    this.status = SaleStatus.initial,
    this.errorMessage,
    this.lastCompletedSale,
  });

  SaleState copyWith({
    List<SaleItem>? items,
    Client? selectedClient,
    double? total,
    SaleStatus? status,
    String? errorMessage,
    Sale? lastCompletedSale,
  }) {
    return SaleState(
      items: items ?? this.items,
      selectedClient: selectedClient ?? this.selectedClient,
      total: total ?? this.total,
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastCompletedSale: lastCompletedSale ?? this.lastCompletedSale,
    );
  }

  @override
  List<Object?> get props => [items, selectedClient, total, status, errorMessage, lastCompletedSale];
}
