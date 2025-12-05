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
              context.read<ProductBloc>().add(ProductLoadRequested());
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
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];

                  return ListTile(
                    leading: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.inventory_2, size: 50),
                    title: Text(product.name),
                    subtitle: Text('Stock: ${product.stock} | \$${product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(product.barcode ?? ''),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
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
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Comienza cargando productos.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
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
