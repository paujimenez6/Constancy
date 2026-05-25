import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/statistics_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/stats_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}
class MockHabitProvider extends Mock implements HabitProvider {}
class MockLeagueProvider extends Mock implements LeagueProvider {}

void main() {
  Provider.debugCheckInvalidValueType = null;

  late MockAuthProvider mockAuth;
  late MockSocialProvider mockSocial;
  late MockHabitProvider mockHabit;
  late MockLeagueProvider mockLeague;

  final tUser = UserModel(
    id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
    correu: 'test@test.com', dataRegistre: DateTime.now(),
  );

  setUp(() {
    mockAuth = MockAuthProvider();
    mockSocial = MockSocialProvider();
    mockHabit = MockHabitProvider();
    mockLeague = MockLeagueProvider();

    when(() => mockAuth.currentUser).thenReturn(tUser);
    when(() => mockHabit.isLoading).thenReturn(false);
    when(() => mockHabit.habits).thenReturn([]);
    when(() => mockHabit.availableCategories).thenReturn(['Salut']);
    when(() => mockHabit.loadMonthlyData(any())).thenAnswer((_) async => {});
    when(() => mockHabit.loadAllTimeData()).thenAnswer((_) async => {});
    when(() => mockHabit.getRecordsForRange(any(), any())).thenAnswer((_) async => []);
    when(() => mockHabit.monthlyRecords).thenReturn([]);
    when(() => mockHabit.allTimeRecords).thenReturn([]);
    when(() => mockHabit.getExpectedHabitsForDate(any())).thenReturn([]);
    when(() => mockHabit.getMonthLabels()).thenReturn(['Gen']);
    when(() => mockHabit.getStatisticsChartData(
      isMensual: any(named: 'isMensual'),
      selectedHabit: any(named: 'selectedHabit'),
      selectedCategory: any(named: 'selectedCategory'),
      viewDate: any(named: 'viewDate'),
      isCumulative: any(named: 'isCumulative'),
      useGroupData: any(named: 'useGroupData'),
    )).thenReturn([]);

    when(() => mockHabit.getStats(
      isMensual: any(named: 'isMensual'),
      habitId: any(named: 'habitId'),
      categoryId: any(named: 'categoryId'),
      useGroupData: any(named: 'useGroupData'),
    )).thenReturn(HabitStats(completionPercentage: 50.0, totalCompleted: 5, totalAccumulatedValue: 10.0, currentStreak: 2, maxStreak: 3));

    when(() => mockLeague.initRealtimeListeners(any())).thenAnswer((_) {});
    when(() => mockLeague.loadUserLeague(any())).thenAnswer((_) async => {});
    when(() => mockLeague.addListener(any())).thenAnswer((_) {});
    when(() => mockLeague.removeListener(any())).thenAnswer((_) {});
    when(() => mockLeague.currentLeague).thenReturn(null);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
        ChangeNotifierProvider<SocialProvider>.value(value: mockSocial),
        ChangeNotifierProvider<HabitProvider>.value(value: mockHabit),
        ChangeNotifierProvider<LeagueProvider>.value(value: mockLeague),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: StatisticsScreen(),
      ),
    );
  }

  testWidgets('Cobertura: Selecció de vistes', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final segmentedButtons = find.byWidgetPredicate((widget) => widget is SegmentedButton);
    expect(segmentedButtons, findsWidgets);

    await tester.tap(find.text('Global'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acumulat'));
    await tester.pumpAndSettle();
  });
}