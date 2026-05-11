import '../models/shop_item_model.dart';
import '../models/inventory_item_model.dart';
import '../../persistence/repositories/shop_repository.dart';

class ShopService {
  final ShopRepository _repository;

  ShopService(this._repository);

  Future<List<ShopItemModel>> fetchShopItems() async {
    final data = await _repository.getShopItems();
    return data.map((json) => ShopItemModel.fromJson(json)).toList();
  }

  Future<List<InventoryItemModel>> fetchUserInventory(String userId) async {
    final data = await _repository.getUserInventory(userId);
    return data.map((json) => InventoryItemModel.fromJson(json)).toList();
  }

  Future<void> purchaseItem(String itemId, String userId) async {
    await _repository.buyItem(itemId, userId);
  }

  Future<void> updateItemStatus(String inventoryId, bool active) async {
    await _repository.toggleItemActive(inventoryId, active);
  }

  Future<void> activateMultiplier(String userId, String inventoryId) async {
    await _repository.activateXpMultiplier(userId, inventoryId);
  }

  Future<void> activateCoinMagnet(String userId, String inventoryId) async {
    await _repository.activateCoinMagnet(userId, inventoryId);
  }
}