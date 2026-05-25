import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:Constancy/domain/models/league_model.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/presentation/screens/search_screen.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockSocialProvider extends Mock implements SocialProvider {}

class MockLeagueProvider extends Mock implements LeagueProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockSocialProvider mockSocialProvider;
  late MockLeagueProvider mockLeagueProvider;

  final tUser = UserModel(
    id: 'u1',
    nickname: 'pau',
    nom: 'Pau',
    cognom: 'S',
    correu: 'test@test.com',
    dataRegistre: DateTime.now(),
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
    registerFallbackValue(() {});
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSocialProvider = MockSocialProvider();
    mockLeagueProvider = MockLeagueProvider();

    when(() => mockAuthProvider.currentUser).thenReturn(tUser);

    when(() => mockLeagueProvider.initRealtimeListeners(any()))
        .thenAnswer((_) async {});

    when(() => mockLeagueProvider.loadUserLeague(any()))
        .thenAnswer((_) async {});

    when(() => mockLeagueProvider.dismissResult())
        .thenAnswer((_) async {});

    when(() => mockLeagueProvider.isLoading).thenReturn(false);

    when(() => mockLeagueProvider.currentLeague).thenReturn(tLeague);

    when(() => mockLeagueProvider.ranking).thenReturn([]);

    when(() => mockLeagueProvider.pendingResult).thenReturn(null);

    when(() => mockLeagueProvider.addListener(any()))
        .thenAnswer((_) {});

    when(() => mockLeagueProvider.removeListener(any()))
        .thenAnswer((_) {});

    when(() => mockLeagueProvider.notifyListeners())
        .thenAnswer((_) {});
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
        ),
        ChangeNotifierProvider<SocialProvider>.value(
          value: mockSocialProvider,
        ),
        ChangeNotifierProvider<LeagueProvider>.value(
          value: mockLeagueProvider,
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ca'),
        ],
        home: SearchScreen(),
      ),
    );
  }

  testWidgets('render inicial', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('OR'), findsOneWidget);

    verify(() => mockLeagueProvider.initRealtimeListeners('u1'))
        .called(1);

    verify(() => mockLeagueProvider.loadUserLeague('u1'))
        .called(1);

    verify(() => mockLeagueProvider.addListener(any()))
        .called(greaterThanOrEqualTo(1));
  });

  testWidgets('mostra loading', (tester) async {
    when(() => mockLeagueProvider.isLoading).thenReturn(true);

    await tester.pumpWidget(createWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra no league', (tester) async {
    when(() => mockLeagueProvider.currentLeague).thenReturn(null);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
  });

  testWidgets('search users success', (tester) async {
    when(() => mockSocialProvider.searchUsers(any()))
        .thenAnswer((_) async => [
      {
        'id': 'u2',
        'nickname': 'TestUser',
        'nom': 'Test',
        'cognom': 'User',
      }
    ]);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'test');

    await tester.pumpAndSettle();

    expect(find.text('TestUser'), findsOneWidget);
  });

  testWidgets('search users empty', (tester) async {
    when(() => mockSocialProvider.searchUsers(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextField), 'abc');

    await tester.pumpAndSettle();

    expect(find.text("No s'han trobat usuaris"), findsOneWidget);
  });

  testWidgets('search users error', (tester) async {
    when(() => mockSocialProvider.searchUsers(any()))
        .thenThrow(Exception('DB ERROR'));

    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextField), 'abc');

    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('clear search', (tester) async {
    when(() => mockSocialProvider.searchUsers(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextField), 'abc');

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));

    await tester.pumpAndSettle();

    expect(find.text('OR'), findsOneWidget);
  });

  testWidgets('dialog promotion', (tester) async {
    final result = LeagueResultModel(
      id: 'r1',
      nivellAnterior: 2,
      nivellNou: 3,
      posicioFinal: 1,
    );

    when(() => mockLeagueProvider.pendingResult)
        .thenReturn(result);

    VoidCallback? capturedListener;

    when(() => mockLeagueProvider.addListener(any()))
        .thenAnswer((invocation) {
      capturedListener = invocation.positionalArguments.first;
    });

    await tester.pumpWidget(createWidget());

    await tester.pump();

    capturedListener?.call();

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('dismiss dialog', (tester) async {
    final result = LeagueResultModel(
      id: 'r1',
      nivellAnterior: 2,
      nivellNou: 3,
      posicioFinal: 1,
    );

    when(() => mockLeagueProvider.pendingResult)
        .thenReturn(result);

    VoidCallback? capturedListener;

    when(() => mockLeagueProvider.addListener(any()))
        .thenAnswer((invocation) {
      capturedListener = invocation.positionalArguments.first;
    });

    await tester.pumpWidget(createWidget());

    await tester.pump();

    capturedListener?.call();

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byType(FilledButton));

    await tester.pumpAndSettle();

    verify(() => mockLeagueProvider.dismissResult())
        .called(1);
  });

  testWidgets('dispose remove listener', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.pumpWidget(const SizedBox());

    verify(() => mockLeagueProvider.removeListener(any()))
        .called(greaterThanOrEqualTo(1));
  });

  testWidgets('search empty query branch', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextField), '');

    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('listener no pending result', (tester) async {
    when(() => mockLeagueProvider.pendingResult)
        .thenReturn(null);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final captured = verify(
          () => mockLeagueProvider.addListener(captureAny()),
    ).captured;

    final listener = captured.first as VoidCallback;

    listener();

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}