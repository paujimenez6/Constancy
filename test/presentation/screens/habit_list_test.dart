import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/profile_habits_list_screen.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/generated/l10n.dart';

void main() {
  HabitModel createHabit({
    required String id,
    required bool isArchived,
    required bool isGroup,
    required double valorObjectiu,
    String? desc,
  }) {
    return HabitModel(
      id: id,
      userId: 'u1',
      titol: 'Habit $id',
      icona: 'star',
      color: '#FF0000',
      dataInici: DateTime.now(),
      createdAt: DateTime.now(),
      isGroup: isGroup,
      valorObjectiu: valorObjectiu,
      unitatMesura: UnitatMesura.vegades,
      periodeObjectiu: PeriodeObjectiu.diari,
      arxivat: isArchived,
      descripcio: desc,
      ratxaActual: 2,
      millorRatxa: 5,
    );
  }

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ca')],
      home: Scaffold(body: child),
    );
  }

  group('buildHabitList Coverage 100%', () {
    testWidgets('Mostra el CircularProgressIndicator si isLoading és true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Builder(builder: (context) {
          return buildHabitList(
            habits: [],
            isLoading: true,
            emptyMessage: 'No hi ha hàbits',
            strings: S.of(context),
            theme: Theme.of(context),
            context: context,
          );
        }),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Mostra el missatge de llista buida si no hi ha hàbits', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Builder(builder: (context) {
          return buildHabitList(
            habits: [],
            isLoading: false,
            emptyMessage: 'Missatge buit test',
            strings: S.of(context),
            theme: Theme.of(context),
            context: context,
          );
        }),
      ));

      expect(find.text('Missatge buit test'), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
    });

    testWidgets('Renderitza correctament la llista cobrint totes les branques (ifs)', (tester) async {
      final habits = [
        createHabit(
            id: '1', isArchived: true, isGroup: true,
            valorObjectiu: 5.0, desc: 'Descripció arxivat'
        ),
        createHabit(
            id: '2', isArchived: false, isGroup: false,
            valorObjectiu: 2.5, desc: ''
        ),
        createHabit(
            id: '3', isArchived: false, isGroup: false,
            valorObjectiu: 1.0, desc: null
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        Builder(builder: (context) {
          return SingleChildScrollView(
            child: buildHabitList(
              habits: habits,
              isLoading: false,
              emptyMessage: 'Buit',
              strings: S.of(context),
              theme: Theme.of(context),
              context: context,
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Habit 1'), findsOneWidget);
      expect(find.text('Habit 2'), findsOneWidget);
      expect(find.text('Habit 3'), findsOneWidget);
      expect(find.byIcon(Icons.groups_rounded), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      expect(find.text('Descripció arxivat'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.emoji_events_rounded), findsNWidgets(3));
    });
  });
}