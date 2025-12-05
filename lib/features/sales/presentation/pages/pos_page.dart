import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/numeric_keypad.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../../services/export_service.dart';
import 'sale_detail_page.dart';

class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Terminal')),
      body: Row(
        children: [
          // Left Side: Product List & Categories
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Product Search / Filter (Placeholder)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Product Grid
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoaded) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return InkWell(
                              onTap: () {
                                context.read<SaleBloc>().add(SaleProductAdded(product));
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: product.imageUrl != null
                                          ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                          : const Icon(Icons.inventory_2, size: 40),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right Side: Cart & Keypad
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Client Selector
                  BlocBuilder<ClientBloc, ClientState>(
                    builder: (context, state) {
                      return ListTile(
                        title: Text(context.watch<SaleBloc>().state.selectedClient?.name ?? 'Select Client'),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          // Show client selection dialog
                          if (state is ClientLoaded) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Select Client'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.clients.length,
                                    itemBuilder: (context, index) {
                                      final client = state.clients[index];
                                      return ListTile(
                                        title: Text(client.name),
                                        onTap: () {
                                          context.read<SaleBloc>().add(SaleClientSelected(client));
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const Divider(),
                  // Cart Items
                  Expanded(
                    child: BlocBuilder<SaleBloc, SaleState>(
                      builder: (context, state) {
                        return ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return ListTile(
                              title: Text(item.product?.name ?? 'Product'),
                              subtitle: Text('${item.quantity} x \$${item.price}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (item.product != null) {
                                        context.read<SaleBloc>().add(SaleProductRemoved(item.product!));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Total & Pay
                  BlocConsumer<SaleBloc, SaleState>(
                      listener: (context, state) {
                        if (state.status == SaleStatus.success) {
                          // Refresh product list to update stock
                          context.read<ProductBloc>().add(ProductLoadRequested());
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sale processed successfully!'),
                              action: SnackBarAction(
                                label: 'Receipt',
                                onPressed: () {
                                  if (state.lastCompletedSale != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SaleDetailPage(sale: state.lastCompletedSale!),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error: Sale data not available')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        } else if (state.status == SaleStatus.failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${state.errorMessage}')),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('\$${state.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: state.items.isEmpty
                                      ? null
                                      : () {
                                          context.read<SaleBloc>().add(SaleProcessed());
                                        },
                                  child: const Text('CHARGE', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Keypad
                    SizedBox(
                      height: 250,
                      child: NumericKeypad(
                        onKeyPressed: (key) {
                          context.read<SaleBloc>().add(SaleNumpadPressed(key));
                        },
                        onEnter: () {
                          // Optional: Trigger charge
                        },
                        onBackspace: () {
                          context.read<SaleBloc>().add(const SaleNumpadPressed('⌫'));
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
