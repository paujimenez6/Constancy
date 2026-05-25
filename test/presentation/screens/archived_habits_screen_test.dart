import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/archived_habits_screen.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockHabitProvider extends Mock implements HabitProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockHabitProvider mockHabitProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockHabitProvider = MockHabitProvider();
    mockAuthProvider = MockAuthProvider();

    registerFallbackValue(HabitModel(
        id: '1', userId: '1', titol: 't', icona: 'i', color: '#000',
        dataInici: DateTime.now(), createdAt: DateTime.now()
    ));
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
        home: ArchivedHabitsScreen(),
      ),
    );
  }

  group('ArchivedHabitsScreen UI Tests', () {
    testWidgets('Mostra icona quan la llista està buida', (tester) async {
      when(() => mockHabitProvider.archivedHabits).thenReturn([]);
      await tester.pumpWidget(createTestWidget());
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('Mostra hàbit i pot desarxivar', (tester) async {
      final tHabit = HabitModel(
          id: 'h1', userId: 'u1', titol: 'Hàbit Test', icona: 'star', color: '#000000',
          dataInici: DateTime.now(), createdAt: DateTime.now(), isGroup: false
      );

      when(() => mockHabitProvider.archivedHabits).thenReturn([tHabit]);
      when(() => mockHabitProvider.archiveHabit('h1', false)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      expect(find.text('Hàbit Test'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Desarxivar'));
      verify(() => mockHabitProvider.archiveHabit('h1', false)).called(1);
    });

    testWidgets('Usuari no admin veu opció sortir del grup', (tester) async {
      final tHabit = HabitModel(
          id: 'h1', userId: 'altreUsuari', titol: 'Hàbit Grupal', icona: 'star', color: '#000000',
          dataInici: DateTime.now(), createdAt: DateTime.now(), isGroup: true
      );

      final user = UserModel(
        id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
        correu: 'pau@test.com', dataRegistre: DateTime.now(),
      );

      when(() => mockHabitProvider.archivedHabits).thenReturn([tHabit]);
      when(() => mockAuthProvider.currentUser).thenReturn(user);

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}