import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/habit_form_screen.dart';
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

  final tHabit = HabitModel(
    id: 'h1', userId: 'u1', titol: 'Hàbit Test', icona: 'star', color: '#000000',
    dataInici: DateTime.now(), createdAt: DateTime.now(), isGroup: false,
    valorObjectiu: 10.0, unitatMesura: UnitatMesura.vegades,
  );

  setUp(() {
    mockHabitProvider = MockHabitProvider();
    mockAuthProvider = MockAuthProvider();

    registerFallbackValue(tHabit);

    final user = UserModel(
      id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
      correu: 'test@test.com', dataRegistre: DateTime.now(),
    );
    when(() => mockAuthProvider.currentUser).thenReturn(user);
  });

  Widget createTestWidget({HabitModel? habit}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitProvider>.value(value: mockHabitProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ca')],
        home: HabitFormScreen(habitToEdit: habit),
      ),
    );
  }

  void setGiantScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('HabitFormScreen 100% Coverage', () {

    testWidgets('Mode creació - Guardar amb èxit', (tester) async {
      setGiantScreen(tester);
      when(() => mockHabitProvider.createHabit(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Nou Hàbit');

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      verify(() => mockHabitProvider.createHabit(any())).called(1);
    });

    testWidgets('Mode edició - Guardar amb èxit', (tester) async {
      setGiantScreen(tester);
      when(() => mockHabitProvider.updateHabit(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget(habit: tHabit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Hàbit Editat');

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      verify(() => mockHabitProvider.updateHabit(any())).called(1);
    });

    testWidgets('Validació: Error si títol buit', (tester) async {
      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      verifyNever(() => mockHabitProvider.createHabit(any()));
    });

    testWidgets('Error en desar (SnackBar vermell)', (tester) async {
      setGiantScreen(tester);
      when(() => mockHabitProvider.createHabit(any())).thenThrow(Exception('Fail DB'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'ErrorTest');

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Validació: recordatoris buits llança SnackBar', (tester) async {
      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Recordatori Test');

      final switchRecordatoris = find.byType(SwitchListTile).last;
      await tester.tap(switchRecordatoris);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => mockHabitProvider.createHabit(any()));
    });
  });
}