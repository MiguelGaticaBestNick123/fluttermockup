import 'product.dart';

class SaleItem {
  final int? id;
  final int productId;
  final int quantity;
  final double price;
  final Product? product; // For UI display

  SaleItem({
    this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class Sale {
  final int? id;
  final int? clientId;
  final int userId;
  final double total;
  final String? date;
  final List<SaleItem> items;
  final int synced; // 0 = false, 1 = true

  Sale({
    this.id,
    this.clientId,
    required this.userId,
    required this.total,
    this.date,
    required this.items,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'user_id': userId,
      'total': total,
      'date': date,
      'synced': synced,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {List<SaleItem>? items}) {
    return Sale(
      id: map['id'],
      clientId: map['client_id'],
      userId: map['user_id'] ?? 0, // Default to 0 if null
      total: (map['total'] as num).toDouble(),
      date: map['date'],
      synced: map['synced'] ?? 0,
      items: items ?? [],
    );
  }
  
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      clientId: json['client_id'],
      userId: json['user_id'],
      total: (json['total'] as num).toDouble(),
      date: json['date'],
      items: (json['items'] as List).map((i) => SaleItem.fromJson(i)).toList(),
      synced: 1,
    );
  }

  Sale copyWith({
    int? id,
    int? clientId,
    int? userId,
    double? total,
    String? date,
    List<SaleItem>? items,
    int? synced,
  }) {
    return Sale(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      date: date ?? this.date,
      items: items ?? this.items,
      synced: synced ?? this.synced,
    );
  }
}
