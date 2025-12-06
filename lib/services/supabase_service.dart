import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- AUTH (Login y eso) ---

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password, String username) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'role': 'operator'}, // Default role
    );
    
    // Nota: El trigger en la DB debería crear el perfil, o lo hacemos a mano.
    // Por ahora confiamos en la magia del backend :v
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // --- PRODUCTOS (La mercadería) ---

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('id', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    final response = await _client
        .from('products')
        .insert(productData)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> updates) async {
    final response = await _client
        .from('products')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteProduct(int id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // --- CLIENTS ---

  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await _client
        .from('clients')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> clientData) async {
    // Fix para el error de clave duplicada: calculamos el ID a mano
    // Porque Postgres a veces se pone rebelde con los serials xD
    final clients = await getClients();
    int maxId = 0;
    if (clients.isNotEmpty) {
      // Buscamos el ID más alto
      for (var c in clients) {
        if (c['id'] > maxId) maxId = c['id'];
      }
    }
    
    final newClientData = Map<String, dynamic>.from(clientData);
    newClientData['id'] = maxId + 1;

    final response = await _client
        .from('clients')
        .insert(newClientData)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateClient(int id, Map<String, dynamic> updates) async {
    final response = await _client
        .from('clients')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteClient(int id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  // --- VENTAS (¡A facturar!) ---

  Future<Map<String, dynamic>> createSale(int clientId, List<Map<String, dynamic>> items, double total) async {
    final userId = _client.auth.currentUser!.id;

    // 1. Crear Cabecera de Venta
    final saleResponse = await _client
        .from('sales')
        .insert({
          'user_id': userId,
          'client_id': clientId,
          'total': total,
        })
        .select()
        .single();

    final saleId = saleResponse['id'];

    // 2. Crear Items de Venta
    final saleItems = items.map((item) {
      return {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      };
    }).toList();

    final insertedItems = await _client.from('sale_items').insert(saleItems).select();

    // 3. Actualizar Stock (Restamos lo que se llevaron)
    for (var item in items) {
      final productId = item['product_id'];
      final quantity = item['quantity'];
      
      final product = await _client.from('products').select('stock').eq('id', productId).single();
      final currentStock = product['stock'] as int;
      
      await _client.from('products').update({'stock': currentStock - quantity}).eq('id', productId);
    }

    // Retornar la venta completa
    final completeSale = Map<String, dynamic>.from(saleResponse);
    completeSale['items'] = insertedItems;
    return completeSale;
  }

  Future<List<Map<String, dynamic>>> getSales() async {
    final response = await _client
        .from('sales')
        .select('*, items:sale_items(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
