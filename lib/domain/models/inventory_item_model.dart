import 'shop_item_model.dart';

class InventoryItemModel {
  final String id;
  final String itemId;
  final int quantitat;
  final bool esActiu;
  final ShopItemModel definicio;

  InventoryItemModel({
    required this.id,
    required this.itemId,
    required this.quantitat,
    required this.esActiu,
    required this.definicio,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      itemId: json['item_id'],
      quantitat: json['quantitat'] ?? 0,
      esActiu: json['es_actiu'] ?? false,
      definicio: ShopItemModel.fromJson(json['shop_items']),
    );
  }
}