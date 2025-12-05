import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../../services/export_service.dart';
import '../../../../core/database/db_helper.dart';
import 'sale_detail_page.dart';

class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            // Mobile Layout (Tabs)
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_view), text: 'Products'),
                      Tab(icon: Icon(Icons.shopping_cart), text: 'Cart'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Products
                        Column(
                          children: [
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
                            Expanded(
                              child: BlocConsumer<ProductBloc, ProductState>(
                                listener: (context, state) {
                                  if (state is ProductLoaded && state.products.isNotEmpty) {
                                    // DEBUG: Show stock of first product to verify update
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text('DEBUG: Loaded ${state.products.length} products. First: ${state.products.first.name} (Stock: ${state.products.first.stock})'),
                                    //     duration: const Duration(seconds: 2),
                                    //   ),
                                    // );
                                  }
                                },
                                builder: (context, state) {
                                  if (state is ProductLoaded) {
                                    return GridView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, // 2 columns for mobile
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
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${product.name} added'), duration: const Duration(milliseconds: 500)),
                                            );
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
                                                      Text('Stock: ${product.stock}', style: TextStyle(fontSize: 12, color: product.stock > 0 ? Theme.of(context).textTheme.bodyMedium?.color : Colors.red)),
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
                        // Tab 2: Cart & Keypad
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              _buildClientSelector(context),
                              const Divider(),
                              Expanded(child: _buildCartList(context)),
                              _buildTotalAndPay(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Desktop Layout (Split View)
            return Row(
              children: [
                // Left Side: Product List & Categories
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (value) {
                            context.read<ProductBloc>().add(ProductSearchRequested(value));
                          },
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<ProductBloc, ProductState>(
                          builder: (context, state) {
                            if (state is ProductLoaded) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(12.0),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  final product = state.products[index];
                                  final isOutOfStock = product.stock <= 0;
                                  return InkWell(
                                    onTap: isOutOfStock ? null : () {
                                      context.read<SaleBloc>().add(SaleProductAdded(product));
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: product.imageUrl != null
                                                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                                  : Container(
                                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                      child: Icon(Icons.inventory_2, size: 40, color: Theme.of(context).iconTheme.color?.withOpacity(0.3)),
                                                    ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '\$${product.price.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isOutOfStock ? Colors.red[100] : Colors.green[100],
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        '${product.stock} left',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: isOutOfStock ? Colors.red[800] : Colors.green[800],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        _buildClientSelector(context),
                        const Divider(),
                        Expanded(child: _buildCartList(context)),
                        _buildTotalAndPay(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildClientSelector(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        final selectedClient = context.watch<SaleBloc>().state.selectedClient;
        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  if (state is ClientLoaded) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Select Customer'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.clients.length,
                            itemBuilder: (context, index) {
                              final client = state.clients[index];
                              return ListTile(
                                leading: CircleAvatar(child: Text(client.name[0])),
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
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, size: 18, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedClient?.name ?? 'Select Customer',
                          style: TextStyle(
                            fontWeight: selectedClient != null ? FontWeight.bold : FontWeight.normal,
                            color: selectedClient != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartList(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = state.items[index];
            return Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.name ?? 'Product',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            if (item.product != null) {
                              context.read<SaleBloc>().add(SaleProductRemoved(item.product!));
                            }
                          },
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () {
                            if (item.product != null) {
                              context.read<SaleBloc>().add(SaleProductAdded(item.product!));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${(item.quantity * item.price).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalAndPay(BuildContext context) {
    return BlocConsumer<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state.status == SaleStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error procesando venta'), backgroundColor: Colors.red),
          );
        } else if (state.status == SaleStatus.success) {
          final clientForReceipt = state.selectedClient;
          
          if (state.lastCompletedSale != null) {
             for (var item in state.lastCompletedSale!.items) {
               context.read<ProductBloc>().add(ProductStockUpdated(item.productId, item.quantity));
             }
             
             Future.delayed(const Duration(milliseconds: 500), () {
               if (context.mounted) {
                 context.read<ProductBloc>().add(ProductLoadRequested());
                 
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => SaleDetailPage(
                       sale: state.lastCompletedSale!,
                       client: clientForReceipt,
                     ),
                   ),
                 );
               }
             });
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Error: Sale data not available')),
             );
          }
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text(
                    '\$${state.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state.items.isEmpty
                      ? null
                      : () {
                          context.read<SaleBloc>().add(SaleProcessed());
                        },
                  child: const Text(
                    'CHARGE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
