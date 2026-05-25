import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/home_screen.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/domain/models/habit_record_model.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockHabitProvider extends Mock implements HabitProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockHabitProvider mockHabitProvider;
  late MockAuthProvider mockAuthProvider;

  final tHabit = HabitModel(
    id: 'h1', userId: 'u1', titol: 'Hàbit Test', icona: 'star', color: '#000000',
    dataInici: DateTime.now(), createdAt: DateTime.now(), isGroup: false,
    valorObjectiu: 10.0, unitatMesura: UnitatMesura.vegades,
  );

  setUp(() {
    mockHabitProvider = MockHabitProvider();
    mockAuthProvider = MockAuthProvider();

    when(() => mockHabitProvider.habits).thenReturn([tHabit]);
    when(() => mockHabitProvider.filteredHabits).thenReturn([tHabit]);
    when(() => mockHabitProvider.dailyRecords).thenReturn({});
    when(() => mockHabitProvider.groupTotals).thenReturn({});
    when(() => mockHabitProvider.isLoading).thenReturn(false);
    when(() => mockHabitProvider.selectedDate).thenReturn(DateTime.now());
    when(() => mockHabitProvider.loadDataForDate(any())).thenAnswer((_) async => {});
    when(() => mockHabitProvider.listenToAllVisibleGroups()).thenAnswer((_) {});
    when(() => mockHabitProvider.stopListeningToAllGroups()).thenAnswer((_) {});

    final user = UserModel(
      id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
      correu: 'test@test.com', dataRegistre: DateTime.now(),
    );
    when(() => mockAuthProvider.currentUser).thenReturn(user);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitProvider>.value(value: mockHabitProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen 100% Coverage', () {
    testWidgets('Mostra carregant si l\'usuari és null', (tester) async {
      when(() => mockAuthProvider.currentUser).thenReturn(null);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Mostra estat buit si no hi ha hàbits', (tester) async {
      when(() => mockHabitProvider.filteredHabits).thenReturn([]);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('Mostra llista hàbits i navega', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final habitFinder = find.text('Hàbit Test');
      expect(habitFinder, findsOneWidget);
      await tester.tap(habitFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('Escut d\'avís s\'activa', (tester) async {
      final record = HabitRecordModel(
          id: 'r1', habitId: 'h1', userId: 'u1', dataRegistre: DateTime.now(),
          isShielded: true, createdAt: DateTime.now(), updatedAt: DateTime.now()
      );
      when(() => mockHabitProvider.dailyRecords).thenReturn({'h1': record});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_rounded), findsWidgets);
    });
  });
}