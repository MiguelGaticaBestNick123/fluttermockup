class Client {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? createdAt;

  Client({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['created_at'],
    );
  }
}
