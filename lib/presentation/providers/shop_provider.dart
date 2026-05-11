import 'package:flutter/material.dart';
import '../../domain/models/shop_item_model.dart';
import '../../domain/models/inventory_item_model.dart';
import '../../domain/services/shop_service.dart';

class ShopProvider extends ChangeNotifier {
  final ShopService _service;

  List<ShopItemModel> _shopItems = [];
  List<InventoryItemModel> _inventory = [];
  bool _isLoading = false;

  ShopProvider(this._service);

  List<ShopItemModel> get shopItems => _shopItems;
  List<InventoryItemModel> get inventory => _inventory;
  bool get isLoading => _isLoading;

  Future<void> loadShopAndInventory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchShopItems(),
        _service.fetchUserInventory(userId),
      ]);
      _shopItems = results[0] as List<ShopItemModel>;
      _inventory = results[1] as List<InventoryItemModel>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buyItem(String itemId, String userId) async {
    await _service.purchaseItem(itemId, userId);
    await loadShopAndInventory(userId);
  }

  Future<void> activateXpMultiplier(String userId, String inventoryId) async {
    try {
      await _service.activateMultiplier(userId, inventoryId);
      await loadShopAndInventory(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> activateCoinMagnet(String userId, String inventoryId) async {
    try {
      await _service.activateCoinMagnet(userId, inventoryId);
      await loadShopAndInventory(userId);
    } catch (e) {
      rethrow;
    }
  }
}