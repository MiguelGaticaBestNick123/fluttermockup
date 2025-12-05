class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? barcode;
  final String? imageUrl;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    this.description,
    this.price = 0.0,
    this.stock = 0,
    this.barcode,
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      barcode: json['barcode'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'barcode': barcode,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'] ?? 0.0,
      stock: map['stock'] ?? 0,
      barcode: map['barcode'],
      imageUrl: map['image_url'],
      createdAt: map['created_at'],
    );
  }
}
