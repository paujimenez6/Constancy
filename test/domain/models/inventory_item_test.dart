import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/inventory_item_model.dart';

void main() {
  group('InventoryItemModel Test', () {
    test('fromJson parseja correctament amb dades vàlides', () {
      final json = {
        'id': 'inv1',
        'item_id': 'item1',
        'quantitat': 3,
        'es_actiu': true,
        'shop_items': {
          'id': 'item1',
          'nom_clau': 'escut',
          'desc_clau': 'descripcio_escut',
          'tipus_efecte': 'proteccio',
          'valor_efecte': 1.0,
          'preu': 100,
          'icona': 'shield'
        }
      };

      final item = InventoryItemModel.fromJson(json);

      expect(item.id, 'inv1');
      expect(item.quantitat, 3);
      expect(item.esActiu, true);
      expect(item.definicio.nomClau, 'escut');
    });
  });
}