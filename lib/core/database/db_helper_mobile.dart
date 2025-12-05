import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/product.dart';
import '../../models/client.dart';
import '../../models/sale.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static const _dbName = 'stocklite.db';
  static const _dbVersion = 2;

  Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL DEFAULT 0.0,
        stock INTEGER DEFAULT 0,
        barcode TEXT,
        image_url TEXT,
        created_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        created_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY,
        client_id INTEGER,
        total REAL NOT NULL,
        date TEXT,
        synced INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY,
        action TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT
      );
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS figures');
      await _onCreate(db, newVersion);
    }
  }

  // CRUD Products
  Future<void> insertProducts(List<Product> products) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    final batch = db.batch();
    for (var p in products) {
      batch.insert('products', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];
    final res = await db.query('products', orderBy: 'name ASC');
    return res.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> clearProducts() async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('products');
  }

  Future<void> insertProduct(Product product) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteProduct(int id) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Clients
  Future<void> insertClients(List<Client> clients) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    final batch = db.batch();
    for (var c in clients) {
      batch.insert('clients', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Client>> getClients() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];
    final res = await db.query('clients', orderBy: 'name ASC');
    return res.map((e) => Client.fromMap(e)).toList();
  }

  Future<void> clearClients() async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('clients');
  }

  Future<void> insertClient(Client client) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.insert('clients', client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteClient(int id) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Sales
  Future<int> insertSale(Sale sale) async {
    if (kIsWeb) return 0;
    final db = await database;
    if (db == null) return 0;
    
    print('DBHelper: Inserting sale: ${sale.toMap()}');
    try {
      return await db.transaction((txn) async {
        int saleId = await txn.insert('sales', sale.toMap());
        print('DBHelper: Sale inserted with ID: $saleId');
        for (var item in sale.items) {
          final itemMap = item.toMap();
          itemMap['sale_id'] = saleId;
          await txn.insert('sale_items', itemMap);
          
          // Update local stock
          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [item.quantity, item.productId],
          );
        }
        return saleId;
      });
    } catch (e) {
      print('DBHelper: Error inserting sale: $e');
      rethrow;
    }
  }

  Future<List<Sale>> getSales() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];

    print('DBHelper: Fetching sales...');
    final salesData = await db.query('sales', orderBy: 'date DESC');
    print('DBHelper: Found ${salesData.length} sales rows');
    
    final List<Sale> sales = [];

    for (var saleMap in salesData) {
      print('DBHelper: Processing sale row: $saleMap');
      final saleId = saleMap['id'] as int;
      final itemsData = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
      
      final items = <SaleItem>[];
      for (var itemMap in itemsData) {
        final productId = itemMap['product_id'] as int;
        final productData = await db.query('products', where: 'id = ?', whereArgs: [productId]);
        
        if (productData.isNotEmpty) {
          final product = Product.fromMap(productData.first);
          items.add(SaleItem(
            productId: productId,
            quantity: itemMap['quantity'] as int,
            price: (itemMap['price'] as num).toDouble(),
            product: product,
          ));
        }
      }

      try {
        sales.add(Sale.fromMap(saleMap).copyWith(items: items));
      } catch (e) {
        print('DBHelper: Error parsing sale $saleId: $e');
      }
    }
    print('DBHelper: Returning ${sales.length} sales');
    return sales;
  }

  // Sync Queue
  Future<void> addToSyncQueue(String action, String endpoint, String payload) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.insert('sync_queue', {
      'action': action,
      'endpoint': endpoint,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
