import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/presentation/providers/shop_provider.dart';
import 'package:Constancy/domain/services/shop_service.dart';
import 'package:Constancy/domain/models/shop_item_model.dart';
import 'package:Constancy/domain/models/inventory_item_model.dart';

class MockShopService extends Mock implements ShopService {}

class FakeShopItem extends Fake implements ShopItemModel {}
class FakeInventoryItem extends Fake implements InventoryItemModel {}

void main() {
  late ShopProvider provider;
  late MockShopService mockService;

  setUp(() {
    mockService = MockShopService();
    provider = ShopProvider(mockService);
  });

  group('ShopProvider 100% Coverage', () {

    test('loadShopAndInventory: èxit i isLoading toggles', () async {
      when(() => mockService.fetchShopItems()).thenAnswer((_) async => [FakeShopItem()]);
      when(() => mockService.fetchUserInventory('u1')).thenAnswer((_) async => [FakeInventoryItem()]);

      final future = provider.loadShopAndInventory('u1');
      expect(provider.isLoading, true);
      await future;

      expect(provider.shopItems.length, 1);
      expect(provider.inventory.length, 1);
      expect(provider.isLoading, false);
    });

    test('buyItem: crida servei i recarrega dades', () async {
      when(() => mockService.purchaseItem('i1', 'u1')).thenAnswer((_) async => {});
      when(() => mockService.fetchShopItems()).thenAnswer((_) async => []);
      when(() => mockService.fetchUserInventory('u1')).thenAnswer((_) async => []);

      await provider.buyItem('i1', 'u1');

      verify(() => mockService.purchaseItem('i1', 'u1')).called(1);
      verify(() => mockService.fetchShopItems()).called(1);
    });

    test('activateXpMultiplier: èxit i rethrow error', () async {
      when(() => mockService.activateMultiplier('u1', 'inv1')).thenAnswer((_) async => {});
      when(() => mockService.fetchShopItems()).thenAnswer((_) async => []);
      when(() => mockService.fetchUserInventory('u1')).thenAnswer((_) async => []);

      await provider.activateXpMultiplier('u1', 'inv1');
      verify(() => mockService.activateMultiplier('u1', 'inv1')).called(1);

      when(() => mockService.activateMultiplier('u1', 'bad')).thenThrow(Exception('Fail'));
      expect(() => provider.activateXpMultiplier('u1', 'bad'), throwsException);
    });

    test('activateCoinMagnet: èxit i rethrow error', () async {
      when(() => mockService.activateCoinMagnet('u1', 'inv1')).thenAnswer((_) async => {});
      when(() => mockService.fetchShopItems()).thenAnswer((_) async => []);
      when(() => mockService.fetchUserInventory('u1')).thenAnswer((_) async => []);

      await provider.activateCoinMagnet('u1', 'inv1');
      verify(() => mockService.activateCoinMagnet('u1', 'inv1')).called(1);

      when(() => mockService.activateCoinMagnet('u1', 'bad')).thenThrow(Exception('Fail'));
      expect(() => provider.activateCoinMagnet('u1', 'bad'), throwsException);
    });
  });
}