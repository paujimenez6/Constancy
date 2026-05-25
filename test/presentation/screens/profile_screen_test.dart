import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/profile_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/achievement_provider.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/achievement_model.dart';
import 'package:Constancy/domain/models/league_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}
class MockHabitProvider extends Mock implements HabitProvider {}
class MockAchievementProvider extends Mock implements AchievementProvider {}
class MockLeagueProvider extends Mock implements LeagueProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockSocialProvider mockSocialProvider;
  late MockHabitProvider mockHabitProvider;
  late MockAchievementProvider mockAchievementProvider;
  late MockLeagueProvider mockLeagueProvider;

  final tUser = UserModel(
    id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
    correu: 'test@test.com', dataRegistre: DateTime.now(),
    puntsXP: 100, monedes: 50, configuracioPrivacitat: TipusPrivacitat.public,
  );

  final tLeague = LeagueModel(
    id: 'l1',
    nomLliga: 'Or',
    nivellLliga: 3,
    color: '#FFD700',
    dataInici: DateTime.now(),
    dataFi: DateTime.now().add(const Duration(days: 7)),
  );

  setUpAll(() {
    registerFallbackValue('u1');
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSocialProvider = MockSocialProvider();
    mockHabitProvider = MockHabitProvider();
    mockAchievementProvider = MockAchievementProvider();
    mockLeagueProvider = MockLeagueProvider();

    when(() => mockAuthProvider.currentUser).thenReturn(tUser);
    when(() => mockAuthProvider.initProfileListener(any())).thenAnswer((_) {});

    when(() => mockHabitProvider.isLoading).thenReturn(false);
    when(() => mockHabitProvider.habits).thenReturn([]);

    when(() => mockAchievementProvider.isLoading).thenReturn(false);
    when(() => mockAchievementProvider.achievements).thenReturn([]);
    when(() => mockAchievementProvider.loadUserAchievements(any())).thenAnswer((_) async => {});
    when(() => mockAchievementProvider.listenToAchievementChanges(any())).thenAnswer((_) {});
    when(() => mockAchievementProvider.stopListeningToAchievementChanges()).thenAnswer((_) {});

    when(() => mockLeagueProvider.currentLeague).thenReturn(tLeague);
    when(() => mockSocialProvider.followersCount).thenReturn(0);
    when(() => mockSocialProvider.followingCount).thenReturn(0);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<SocialProvider>.value(value: mockSocialProvider),
        ChangeNotifierProvider<HabitProvider>.value(value: mockHabitProvider),
        ChangeNotifierProvider<AchievementProvider>.value(value: mockAchievementProvider),
        ChangeNotifierProvider<LeagueProvider>.value(value: mockLeagueProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: ProfileScreen(isDirectTab: true),
      ),
    );
  }

  void setGiantScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('Renderització bàsica, estadístiques i logout', (tester) async {
    setGiantScreen(tester);
    when(() => mockAuthProvider.signOut()).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('pau'), findsOneWidget);
    expect(find.text('100 XP'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Tancar sessió'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Tancar sessió'));
    await tester.pumpAndSettle();

    verify(() => mockAuthProvider.signOut()).called(1);
  });

  testWidgets('Obre detalls de l\'assoliment i reclama la recompensa', (tester) async {
    setGiantScreen(tester);
    final tAch = AchievementModel(
      id: 'a1', icona: 'bolt', condicioCodi: 'primerHabit',
      valorObjectiu: 10, progresActual: 10, completat: true, reclamat: false,
    );

    when(() => mockAchievementProvider.achievements).thenReturn([tAch]);
    when(() => mockAchievementProvider.claimAchievementReward(any(), any())).thenAnswer((_) async => 100);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bolt));
    await tester.pumpAndSettle();

    expect(find.text('RECOLLIR RECOMPENSA'), findsOneWidget);

    await tester.tap(find.text('RECOLLIR RECOMPENSA'));
    await tester.pumpAndSettle();

    verify(() => mockAchievementProvider.claimAchievementReward('a1', 'u1')).called(1);

    expect(find.text('100 XP'), findsWidgets);
  });

  testWidgets('Obre usuaris seguits (Following)', (tester) async {
    setGiantScreen(tester);
    when(() => mockSocialProvider.getFollowingList(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seguint'));
    await tester.pumpAndSettle();

    verify(() => mockSocialProvider.getFollowingList('u1')).called(1);
  });
}