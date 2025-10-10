// lib/data/sample_products.dart
import '../models/product.dart';

final sampleProducts = List<Product>.generate(
  8,
  (i) => Product(
    id: i,
    title: 'Producto ${i + 1}',
    subtitle: 'Categoría ${i % 3 + 1}',
    description: 'Descripción detallada del producto ${i + 1}. Aquí puede ir información, especificaciones y detalles de interés. Este prototipo muestra cómo se vería la ficha de producto.',
    price: 9.99 + i * 5,
    imageUrl: 'https://picsum.photos/seed/product${i + 1}/600/400',
  ),
);