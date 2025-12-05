import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/product.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../features/sync/presentation/bloc/sync_bloc.dart';
import '../../../../features/sync/presentation/bloc/sync_event.dart';
import '../../../../features/sync/presentation/bloc/sync_state.dart';
import '../../../../core/presentation/bloc/theme_cubit.dart';
import 'product_form_page.dart';
import '../../../../core/presentation/widgets/sync_status_indicator.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockLite POS'),
        actions: [
          const SyncStatusIndicator(),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: () {
              context.read<SyncBloc>().add(SyncStarted());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Iniciando sincronización...')),
              );
            },
          ),
          // Navigation buttons removed in favor of BottomNavigationBar
          /*
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'Punto de Venta',
            onPressed: () {
              Navigator.pushNamed(context, '/pos');
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Clientes',
            onPressed: () {
              Navigator.pushNamed(context, '/clients');
            },
          ),
          */
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(ProductRefreshRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Cambiar Tema',
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No se encontraron productos.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(ProductLoadRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = state.products[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 60, 
                                      height: 60, 
                                      color: Colors.grey[200], 
                                      child: const Icon(Icons.broken_image, color: Colors.grey)
                                    ),
                              )
                            : Container(
                                width: 60, 
                                height: 60, 
                                color: Colors.grey[200], 
                                child: Icon(Icons.inventory_2, size: 30, color: Colors.grey[400])
                              ),
                      ),
                      title: Text(
                        product.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Stock: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.w500)),
                          Text('\$${product.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Editar')]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))]),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductFormPage(product: product),
                              ),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Producto'),
                                content: const Text('¿Estás seguro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (product.id != null) {
                                        context.read<ProductBloc>().add(ProductDeleted(product.id!));
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is ProductError) {
            if (state.message.contains('401')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_clock, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text('Session expired. Please log in again.', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Comienza cargando productos.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
