import 'package:Constancy/domain/models/league_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/other_profile_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/achievement_provider.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/social_stats_model.dart';
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
    id: 'u2', nickname: 'TestUser', nom: 'Test', cognom: 'User',
    correu: 'test@test.com', dataRegistre: DateTime.now(),
    configuracioPrivacitat: TipusPrivacitat.public,
  );

  setUpAll(() {
    registerFallbackValue('u1');
    registerFallbackValue('u2');
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSocialProvider = MockSocialProvider();
    mockHabitProvider = MockHabitProvider();
    mockAchievementProvider = MockAchievementProvider();
    mockLeagueProvider = MockLeagueProvider();

    when(() => mockAuthProvider.currentUser).thenReturn(UserModel(
        id: 'u1', nickname: 'me', nom: '', cognom: '', correu: '', dataRegistre: DateTime.now()));

    when(() => mockSocialProvider.getFollowStatus(any()))
        .thenAnswer((_) async => {'isFollowing': false, 'isPending': false});
    when(() => mockSocialProvider.getOtherUserStats(any()))
        .thenAnswer((_) async => SocialStats(followersCount: 0, followingCount: 0, hasPendingRequests: false));

    when(() => mockHabitProvider.profileHabits).thenReturn([]);
    when(() => mockHabitProvider.isLoading).thenReturn(false);
    when(() => mockHabitProvider.loadProfileHabits(any())).thenAnswer((_) async => {});
    when(() => mockAchievementProvider.achievements).thenReturn([]);
    when(() => mockAchievementProvider.isLoading).thenReturn(false);
    when(() => mockAchievementProvider.loadUserAchievements(any())).thenAnswer((_) async => {});
    when(() => mockAchievementProvider.listenToAchievementChanges(any())).thenAnswer((_) {});
    when(() => mockAchievementProvider.stopListeningToAchievementChanges()).thenAnswer((_) {});
    when(() => mockLeagueProvider.loadAnyUserLeague(any())).thenAnswer((_) async => null);
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
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ca')],
        home: OtherProfileScreen(userData: tUser),
      ),
    );
  }

  testWidgets('Renderitza el perfil i carrega dades', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('TestUser'), findsOneWidget);
    verify(() => mockSocialProvider.getFollowStatus('u2')).called(1);
  });

  testWidgets('Mostra missatge de privacitat si el perfil és privat', (tester) async {
    final privateUser = UserModel(
      id: 'u3', nickname: 'PrivateUser', nom: 'P', cognom: 'U',
      correu: 'a@a.com', dataRegistre: DateTime.now(),
      configuracioPrivacitat: TipusPrivacitat.privat,
    );

    await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<SocialProvider>.value(value: mockSocialProvider),
            ChangeNotifierProvider<HabitProvider>.value(value: mockHabitProvider),
            ChangeNotifierProvider<AchievementProvider>.value(value: mockAchievementProvider),
            ChangeNotifierProvider<LeagueProvider>.value(value: mockLeagueProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [S.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            supportedLocales: const [Locale('ca')],
            home: OtherProfileScreen(userData: privateUser),
          ),
        )
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });

  testWidgets('Mostra estat REQUEST PENDING al botó', (tester) async {
    when(() => mockSocialProvider.getFollowStatus(any()))
        .thenAnswer((_) async => {'isFollowing': false, 'isPending': true});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
  });

  testWidgets('Mostra league badge si existeix', (tester) async {
    when(() => mockLeagueProvider.loadAnyUserLeague(any()))
        .thenAnswer((_) async => LeagueModel(color: '#FF0000', nomLliga: 'Gold', id: '', nivellLliga: 2, dataInici: DateTime.now(), dataFi: DateTime.now()));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });
}