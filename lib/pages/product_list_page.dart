// lib/pages/product_list_page.dart
import 'package:flutter/material.dart';
import '../data/sample_products.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') Navigator.pushNamed(context, '/about');
              if (value == 'team') Navigator.pushNamed(context, '/team');
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'about', child: Text('Acerca de')),
              PopupMenuItem(value: 'team', child: Text('Integrantes')),
            ],
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: sampleProducts.length,
        itemBuilder: (ctx, idx) {
          final p = sampleProducts[idx];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              contentPadding: EdgeInsets.all(8),
              leading: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(p.imageUrl, fit: BoxFit.cover),
              ),
              title: Text(p.title),
              subtitle: Text(p.subtitle + ' • \$${p.price.toStringAsFixed(2)}'),
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
              ),
            ),
          );
        },
      ),
    );
  }
}