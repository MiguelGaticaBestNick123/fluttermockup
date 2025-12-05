import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- AUTH ---

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
    
    // Note: Trigger in DB should handle profile creation, or we do it manually here if needed.
    // For now, we rely on the metadata or a trigger.
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // --- PRODUCTS ---

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
    final response = await _client
        .from('clients')
        .insert(clientData)
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

  // --- SALES ---

  Future<Map<String, dynamic>> createSale(int clientId, List<Map<String, dynamic>> items, double total) async {
    final userId = _client.auth.currentUser!.id;

    // 1. Create Sale Header
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

    // 2. Create Sale Items
    final saleItems = items.map((item) {
      return {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      };
    }).toList();

    final insertedItems = await _client.from('sale_items').insert(saleItems).select();

    // 3. Update Stock
    for (var item in items) {
      final productId = item['product_id'];
      final quantity = item['quantity'];
      
      final product = await _client.from('products').select('stock').eq('id', productId).single();
      final currentStock = product['stock'] as int;
      
      await _client.from('products').update({'stock': currentStock - quantity}).eq('id', productId);
    }

    // Return complete sale object
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
