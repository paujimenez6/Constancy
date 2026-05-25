import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:Constancy/domain/models/achievement_model.dart';
import 'package:Constancy/generated/l10n.dart';

void main() {
  group('AchievementModel Test', () {
    test('fromJson parseja correctament un JSON complert', () {
      final json = {
        'id': 'uuid-1234',
        'icona': 'trophy',
        'condicio_codi': 'primerHabit',
        'valor_objectiu': 10,
        'progres_actual': 5,
        'completat': true,
        'data_obtencio': '2026-05-21T10:00:00Z',
        'reclamat': true,
      };

      final model = AchievementModel.fromJson(json);

      expect(model.id, 'uuid-1234');
      expect(model.icona, 'trophy');
      expect(model.condicioCodi, 'primerHabit');
      expect(model.valorObjectiu, 10);
      expect(model.progresActual, 5);
      expect(model.completat, true);
      expect(model.dataObtencio, DateTime.parse('2026-05-21T10:00:00Z'));
      expect(model.reclamat, true);
    });

    test('fromJson aplica valors per defecte si falten camps al JSON', () {
      final json = {'id': 'uuid-5678'};
      final model = AchievementModel.fromJson(json);

      expect(model.id, 'uuid-5678');
      expect(model.icona, 'star');
      expect(model.condicioCodi, '');
      expect(model.valorObjectiu, 1);
      expect(model.progresActual, 0);
      expect(model.completat, false);
      expect(model.dataObtencio, isNull);
      expect(model.reclamat, false);
    });

    testWidgets('getNom i getDescripcio cobreixen tots els switch cases', (WidgetTester tester) async {
      final allCodes = [
        'primerHabit', 'completatHabits50', 'ratxa50', 'grupalsUnits5',
        'seguirAmics10', 'missionsCompletades50', 'compresBotiga25',
        'utilitzarInventari25', 'lligaOr', 'lligaDiamant', 'fotoPerfil',
        'activarMfa', 'acumularXp1000', 'acumularMonedes1000', 'diaPerfecte10'
      ];

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
            builder: (BuildContext context) {
              for (final code in allCodes) {
                final model = AchievementModel(
                  id: 'test', icona: 'star', condicioCodi: code, valorObjectiu: 1,
                );

                final nom = model.getNom(context);
                final desc = model.getDescripcio(context);

                expect(nom, isNotEmpty, reason: 'El nom per $code hauria de tenir traducció');
                expect(desc, isNotEmpty, reason: 'La descripció per $code hauria de tenir traducció');
              }

              final modelDefault = AchievementModel(id: 'def', icona: 'star', condicioCodi: 'unknown', valorObjectiu: 1);
              expect(modelDefault.getNom(context), '');
              expect(modelDefault.getDescripcio(context), '');

              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    test('dataFormatada retorna string buit o formatat correctament', () {
      Intl.defaultLocale = 'ca';
      final modelSenseData = AchievementModel(id: '1', icona: 'x', condicioCodi: 'x', valorObjectiu: 1);
      final modelAmbData = AchievementModel(
        id: '2', icona: 'x', condicioCodi: 'x', valorObjectiu: 1,
        dataObtencio: DateTime(2026, 5, 21),
      );

      expect(modelSenseData.dataFormatada, '');
      expect(modelAmbData.dataFormatada.contains('2026'), isTrue);
    });
  });
}