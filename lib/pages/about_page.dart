// lib/pages/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Acerca de')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8),
            Image.network('https://picsum.photos/seed/about/800/400', height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text('Aplicación prototipo desarrollada en Flutter para mostrar navegación entre pantallas, lista de productos y detalle.', textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: Text('Volver a principal')),
          ],
        ),
      ),
    );
  }
}