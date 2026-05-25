import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/shop_item_model.dart';

void main() {
  group('ShopItemModel Test', () {
    test('fromJson parseja correctament amb dades vàlides', () {
      final json = {
        'id': 's1',
        'nom_clau': 'escut',
        'desc_clau': 'desc',
        'tipus_efecte': 'proteccio',
        'valor_efecte': 1.0,
        'preu': 50,
        'icona': 'shield'
      };

      final item = ShopItemModel.fromJson(json);

      expect(item.id, 's1');
      expect(item.valorEfecte, 1.0);
      expect(item.preu, 50);
    });

    test('fromJson maneja valors per defecte si el JSON és parcial', () {
      final json = {'id': 's1'};
      final item = ShopItemModel.fromJson(json);

      expect(item.nomClau, '');
      expect(item.icona, 'star');
      expect(item.preu, 0);
    });
  });
}