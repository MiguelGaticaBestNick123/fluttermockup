import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
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
              child: ListView.builder(
                itemCount: state.clients.length,
                itemBuilder: (context, index) {
                  final client = state.clients[index];

                  return ListTile(
                    leading: CircleAvatar(child: Text(client.name[0])),
                    title: Text(client.name),
                    subtitle: Text(client.email ?? client.phone ?? 'Sin contacto'),
                    trailing: PopupMenuButton(
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
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          } else if (state is ClientError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Comienza cargando clientes.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
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
