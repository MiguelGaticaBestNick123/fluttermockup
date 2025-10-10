import '../models/product.dart';

// Generamos 20 productos para asegurar que la lista necesite scroll
final sampleProducts = List<Product>.generate(
  20,
  (i) => Product(
    id: i,
    title: 'Producto ${i + 1}',
    subtitle: 'Categoría ${i % 4 + 1}',
    description: 'Descripción detallada del producto ${i + 1}. Aquí puede ir información, especificaciones y detalles de interés. Este prototipo muestra cómo se vería la ficha de producto.',
    price: 10.99 + i * 5,
    imageUrl: 'https://picsum.photos/seed/product${i + 1}/600/400',
  ),
);