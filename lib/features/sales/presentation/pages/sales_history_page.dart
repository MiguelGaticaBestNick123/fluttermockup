import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/sale.dart';
import '../bloc/sales_history_bloc.dart';
import 'sale_detail_page.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load on build
    context.read<SalesHistoryBloc>().add(SalesHistoryLoadRequested());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SalesHistoryBloc>().add(SalesHistoryLoadRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesHistoryBloc, SalesHistoryState>(
        builder: (context, state) {
          if (state is SalesHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesHistoryLoaded) {
            if (state.sales.isEmpty) {
              return const Center(child: Text('No hay ventas registradas.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.sales.length,
              itemBuilder: (context, index) {
                final sale = state.sales[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.blueGrey),
                    title: Text('Venta #${sale.id ?? "Pendiente"}'),
                    subtitle: Text(sale.date?.split('T')[0] ?? 'Fecha desconocida'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${sale.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (sale.synced == 0)
                          const Icon(Icons.cloud_off, size: 16, color: Colors.orange)
                        else
                          const Icon(Icons.cloud_done, size: 16, color: Colors.green),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleDetailPage(sale: sale),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is SalesHistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Cargando historial...'));
        },
      ),
    );
  }
}
