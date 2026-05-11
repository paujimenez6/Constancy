import 'package:supabase_flutter/supabase_flutter.dart';

class ShopRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getShopItems() async {
    final response = await _supabase
        .from('shop_items')
        .select()
        .eq('actiu', true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getUserInventory(String userId) async {
    final response = await _supabase
        .from('user_inventory')
        .select('*, shop_items(*)')
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> buyItem(String itemId, String userId) async {
    await _supabase.rpc('comprar_objecte', params: {
      'p_item_id': itemId,
      'p_user_id': userId,
    });
  }

  Future<void> toggleItemActive(String inventoryId, bool active) async {
    await _supabase
        .from('user_inventory')
        .update({'es_actiu': active})
        .eq('id', inventoryId);
  }

  Future<void> activateXpMultiplier(String userId, String inventoryId) async {
    await _supabase.rpc('activar_multiplicador_xp', params: {
      'p_user_id': userId,
      'p_inventory_id': inventoryId,
    });
  }

  Future<void> activateCoinMagnet(String userId, String inventoryId) async {
    await _supabase.rpc('activar_imant_monedes', params: {
      'p_user_id': userId,
      'p_inventory_id': inventoryId,
    });
  }
}