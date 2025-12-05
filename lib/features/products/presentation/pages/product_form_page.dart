import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_button.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final barcode = _barcodeController.text.isEmpty ? null : _barcodeController.text;
      final description = _descriptionController.text.isEmpty ? null : _descriptionController.text;

      if (widget.product == null) {
        // Create
        final newProduct = Product(
          id: 0, // ID ignored by backend on create
          name: name,
          price: price,
          stock: stock,
          barcode: barcode,
          description: description,
          createdAt: DateTime.now().toIso8601String(),
        );
        context.read<ProductBloc>().add(ProductCreated(newProduct));
      } else {
        // Update
        final updatedProduct = Product(
          id: widget.product!.id,
          name: name,
          price: price,
          stock: stock,
          barcode: barcode,
          description: description,
          createdAt: widget.product!.createdAt,
          imageUrl: widget.product!.imageUrl,
        );
        context.read<ProductBloc>().add(ProductUpdated(updatedProduct));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is ProductOperationFailure) {
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
                  controller: _priceController,
                  label: 'Precio',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _stockController,
                  label: 'Stock',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _barcodeController,
                  label: 'Código de Barras (Opcional)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción (Opcional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Guardar',
                  onPressed: _saveProduct,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
