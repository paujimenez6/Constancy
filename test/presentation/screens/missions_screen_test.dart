import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/missions_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/mission_provider.dart';
import 'package:Constancy/presentation/providers/shop_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/mission_model.dart';
import 'package:Constancy/domain/models/inventory_item_model.dart';
import 'package:Constancy/domain/models/shop_item_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockMissionProvider extends Mock implements MissionProvider {}
class MockShopProvider extends Mock implements ShopProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockMissionProvider mockMissionProvider;
  late MockShopProvider mockShopProvider;
  late MockSocialProvider mockSocialProvider;

  final missionTypes = ['habits', 'social', 'xp', 'perfect_day', 'league', 'shop_buy', 'inventory_use'];

  List<UserMissionModel> createMockMissions() {
    return missionTypes.map((type) => UserMissionModel(
        id: 'm_$type', progresActual: 0, completada: true, reclamada: false,
        definicio: MissionModel(
            id: 'd_$type', tipus: type, titolClau: 'mission_${type}_title',
            descripcioClau: 'mission_${type}_desc', objectiu: 10,
            recompensaXp: 10, recompensaMonedes: 10
        )
    )).toList();
  }

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue('u1');
    registerFallbackValue(createMockMissions().first);
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockMissionProvider = MockMissionProvider();
    mockShopProvider = MockShopProvider();
    mockSocialProvider = MockSocialProvider();

    final user = UserModel(
      id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
      correu: 'test@test.com', dataRegistre: DateTime.now(),
    );

    when(() => mockAuthProvider.currentUser).thenReturn(user);
    when(() => mockSocialProvider.hasPendingRequests).thenReturn(false);

    when(() => mockMissionProvider.initMissionsListener(any())).thenAnswer((_) {});
    when(() => mockMissionProvider.isLoading).thenReturn(false);
    when(() => mockMissionProvider.missions).thenReturn(createMockMissions());

    when(() => mockShopProvider.loadShopAndInventory(any())).thenAnswer((_) async => {});
    when(() => mockShopProvider.inventory).thenReturn([
      InventoryItemModel(
          id: 'i1',
          itemId: 's1',
          quantitat: 1,
          esActiu: false,
          definicio: ShopItemModel(id: 's1', nomClau: 'Reroll', descClau: '...', tipusEfecte: 'mission_reroll', valorEfecte: 1, preu: 0, icona: 'star')
      )
    ]);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<MissionProvider>.value(value: mockMissionProvider),
        ChangeNotifierProvider<ShopProvider>.value(value: mockShopProvider),
        ChangeNotifierProvider<SocialProvider>.value(value: mockSocialProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: MissionsScreen(),
      ),
    );
  }

  testWidgets('Test flux complet: UI i accions', (tester) async {
    when(() => mockMissionProvider.reroll(any(), any(), any())).thenAnswer((_) async => {});
    when(() => mockMissionProvider.notifyAction(any(), any(), any())).thenAnswer((_) async => {});
    when(() => mockMissionProvider.claimMission(any(), any(), any())).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.refresh_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    verify(() => mockMissionProvider.reroll('u1', any(), any())).called(1);

    await tester.tap(find.text('Recollir recompensa').first);
    await tester.pumpAndSettle();
    verify(() => mockMissionProvider.claimMission(any(), 'u1', any())).called(1);
  });
}