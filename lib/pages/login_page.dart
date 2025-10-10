import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    // 1. Validar que los campos no estén vacíos
    if (user.isEmpty || pass.isEmpty) {
      _showErrorDialog('Ambos campos son obligatorios.');
      return;
    }

    // 2. Validar las credenciales correctas
    if (user == 'duoc2025' && pass == 'duoc2025') {
      // Si son correctas, navegar a la página de productos
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Si son incorrectas, mostrar alerta
      _showErrorDialog('Los datos son incorrectos.');
    }
  }

  // Función auxiliar para mostrar el diálogo de error
  void _showErrorDialog(String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Ingresar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}