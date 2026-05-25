import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/generated/l10n.dart';

void main() {
  group('HabitModel Test', () {
    test('fromJson parseja correctament un JSON complet', () {
      final json = {
        'id': 'hab1',
        'user_id': 'user1',
        'titol': 'Beure aigua',
        'icona': 'water_drop',
        'color': '#FFFFFF',
        'periode_objectiu': 'setmanal',
        'valor_objectiu': 5.0,
        'unitat_mesura': 'ml',
        'data_inici': '2026-05-21',
        'data_fi': '2026-06-21',
        'created_at': '2026-05-21T10:00:00Z',
        'is_group': true,
        'hores_recordatori': ['09:00', '18:00']
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.id, 'hab1');
      expect(habit.periodeObjectiu, PeriodeObjectiu.setmanal);
      expect(habit.dataFi, isNotNull);
      expect(habit.horesRecordatori, ['09:00', '18:00']);
    });

    test('fromJson maneja valors nulls i invàlids (cobertura orElse)', () {
      final json = {
        'id': '1',
        'data_inici': '2026-05-21',
        'created_at': '2026-05-21T10:00:00Z',
        'periode_objectiu': 'invalida',
        'unitat_mesura': 'invalida'
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.periodeObjectiu, PeriodeObjectiu.diari);
      expect(habit.unitatMesura, UnitatMesura.vegades);
      expect(habit.dataFi, isNull);
    });

    testWidgets('Extensions de Periode i Unitat cobreixen tots els switch cases', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: const Locale('ca'),
          home: Builder(
            builder: (context) {
              for (var p in PeriodeObjectiu.values) {
                p.getLocalizedString(context);
              }
              for (var u in UnitatMesura.values) {
                u.getLocalizedString(context);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    test('toJson converteix correctament a map', () {
      final habit = HabitModel(
        id: '1', userId: 'u1', titol: 'Test', icona: 'star', color: '#000',
        dataInici: DateTime(2026, 5, 21),
        createdAt: DateTime.now(),
        horesRecordatori: ['10:00'],
      );

      final json = habit.toJson();
      expect(json['titol'], 'Test');
      expect(json['data_inici'], '2026-05-21');
      expect(json['hores_recordatori'], ['10:00']);
    });

    test('copyWith manté valors quan no es passen', () {
      final habit = HabitModel(
        id: '1', userId: 'u1', titol: 'Original', icona: 'star', color: '#000',
        dataInici: DateTime.now(), createdAt: DateTime.now(),
      );

      final updated = habit.copyWith(titol: 'Modificat');

      expect(updated.titol, 'Modificat');
      expect(updated.icona, habit.icona);
    });
  });
}