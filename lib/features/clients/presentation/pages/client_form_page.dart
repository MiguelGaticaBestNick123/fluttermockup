import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/client.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_button.dart';

class ClientFormPage extends StatefulWidget {
  final Client? client;

  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text.isEmpty ? null : _emailController.text;
      final phone = _phoneController.text.isEmpty ? null : _phoneController.text;

      if (widget.client == null) {
        // Create
        final newClient = Client(
          id: 0,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now().toIso8601String(),
        );
        context.read<ClientBloc>().add(ClientCreated(newClient));
      } else {
        // Update
        final updatedClient = Client(
          id: widget.client!.id,
          name: name,
          email: email,
          phone: phone,
          createdAt: widget.client!.createdAt,
        );
        context.read<ClientBloc>().add(ClientUpdated(updatedClient));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      ),
      body: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is ClientOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre',
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email (Opcional)',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono (Opcional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Guardar',
                  onPressed: _saveClient,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
