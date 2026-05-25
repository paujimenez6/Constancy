import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/domain/services/shop_service.dart';
import 'package:Constancy/persistence/repositories/shop_repository.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late ShopService service;
  late MockShopRepository mockRepository;

  setUp(() {
    mockRepository = MockShopRepository();
    service = ShopService(mockRepository);
  });

  group('ShopService Coverage (100%)', () {

    test('fetchShopItems mapeja correctament el JSON', () async {
      when(() => mockRepository.getShopItems()).thenAnswer((_) async => [
        {
          'id': 'i1',
          'nom_clau': 'Espasa',
          'desc_clau': 'desc',
          'tipus_efecte': 'arma',
          'valor_efecte': 10.0,
          'preu': 100,
          'icona': 'star'
        }
      ]);

      final items = await service.fetchShopItems();
      expect(items.length, 1);
      expect(items.first.id, 'i1');
      expect(items.first.nomClau, 'Espasa');
    });

    test('fetchUserInventory mapeja correctament amb ShopItem anidat', () async {
      final mockData = [
        {
          'id': 'inv1',
          'item_id': 'i1',
          'quantitat': 1,
          'es_actiu': true,
          'shop_items': {
            'id': 'i1',
            'nom_clau': 'Espasa',
            'desc_clau': 'desc',
            'tipus_efecte': 'arma',
            'valor_efecte': 10.0,
            'preu': 100,
            'icona': 'star'
          }
        }
      ];

      when(() => mockRepository.getUserInventory('u1')).thenAnswer((_) async => mockData);

      final inv = await service.fetchUserInventory('u1');
      expect(inv.length, 1);
      expect(inv.first.id, 'inv1');
      expect(inv.first.definicio.nomClau, 'Espasa');
    });

    test('Accions CRUD criden al repositori correctament', () async {
      when(() => mockRepository.buyItem(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.toggleItemActive(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.activateXpMultiplier(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.activateCoinMagnet(any(), any())).thenAnswer((_) async => {});

      await service.purchaseItem('i1', 'u1');
      await service.updateItemStatus('inv1', true);
      await service.activateMultiplier('u1', 'inv1');
      await service.activateCoinMagnet('u1', 'inv1');

      verify(() => mockRepository.buyItem('i1', 'u1')).called(1);
      verify(() => mockRepository.toggleItemActive('inv1', true)).called(1);
      verify(() => mockRepository.activateXpMultiplier('u1', 'inv1')).called(1);
      verify(() => mockRepository.activateCoinMagnet('u1', 'inv1')).called(1);
    });
  });
}