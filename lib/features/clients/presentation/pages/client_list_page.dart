import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../bloc/client_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'client_form_page.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ClientBloc>().add(ClientLoadRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<ClientBloc, ClientState>(
        builder: (context, state) {
          if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientLoaded) {
            if (state.clients.isEmpty) {
              return const Center(child: Text('No se encontraron clientes.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClientBloc>().add(ClientLoadRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.clients.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final client = state.clients[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                        ),
                      ),
                      title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.contact_phone, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(client.email ?? client.phone ?? 'Sin contacto', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
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
                                builder: (context) => ClientFormPage(client: client),
                              ),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Cliente'),
                                content: const Text('¿Estás seguro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (client.id != null) {
                                        context.read<ClientBloc>().add(ClientDeleted(client.id!));
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
          } else if (state is ClientError) {
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
          return const Center(child: Text('Comienza cargando clientes.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientFormPage()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
