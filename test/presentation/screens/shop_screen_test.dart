import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/shop_screen.dart';
import 'package:Constancy/presentation/providers/shop_provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/mission_provider.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/shop_item_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockShopProvider extends Mock implements ShopProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockMissionProvider extends Mock implements MissionProvider {}
class MockHabitProvider extends Mock implements HabitProvider {}

void main() {
  late MockShopProvider shopProvider;
  late MockAuthProvider authProvider;
  late MockMissionProvider missionProvider;
  late MockHabitProvider habitProvider;

  setUp(() {
    shopProvider = MockShopProvider();
    authProvider = MockAuthProvider();
    missionProvider = MockMissionProvider();
    habitProvider = MockHabitProvider();

    when(() => shopProvider.loadShopAndInventory(any())).thenAnswer((_) async {});
    when(() => shopProvider.isLoading).thenReturn(false);
    when(() => shopProvider.shopItems).thenReturn([
      ShopItemModel(
        id: 'item1',
        nomClau: 'item_xp_multiplier_title',
        descClau: 'item_xp_multiplier_desc',
        tipusEfecte: 'xp_multiplier',
        valorEfecte: 2,
        preu: 50,
        icona: 'bolt_rounded',
      )
    ]);
    when(() => shopProvider.inventory).thenReturn([]);
  });

  Widget makeWidget({required int coins}) {
    when(() => authProvider.currentUser).thenReturn(
      UserModel(
        id: 'u1', nickname: 'test', nom: 'Nom', cognom: 'Cognom',
        correu: 'test@test.com', dataRegistre: DateTime.now(),
        monedes: coins,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShopProvider>.value(value: shopProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<MissionProvider>.value(value: missionProvider),
        ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: ShopScreen(),
      ),
    );
  }

  testWidgets('renders shop screen correctly', (tester) async {
    await tester.pumpWidget(makeWidget(coins: 100));
    await tester.pumpAndSettle();

    expect(find.text('BOTIGA'), findsOneWidget);
    expect(find.text('INVENTARI'), findsOneWidget);
  });

  testWidgets('buy button disabled when not affordable', (tester) async {
    await tester.pumpWidget(makeWidget(coins: 0));
    await tester.pumpAndSettle();

    final buttons = find.byType(ElevatedButton);
    expect(buttons, findsWidgets);

    final widgetButtons = tester.widgetList<ElevatedButton>(buttons);
    for (final b in widgetButtons) {
      expect(b.onPressed, isNull);
    }
  });

  testWidgets('shows loading state', (tester) async {
    when(() => shopProvider.isLoading).thenReturn(true);

    await tester.pumpWidget(makeWidget(coins: 100));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}