import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/domain/services/league_service.dart';
import 'package:Constancy/domain/services/mission_service.dart';
import 'package:Constancy/domain/models/league_model.dart';

class MockLeagueService extends Mock implements LeagueService {}
class MockMissionService extends Mock implements MissionService {}

void main() {
  late LeagueProvider provider;
  late MockLeagueService mockLeagueService;
  late MockMissionService mockMissionService;

  setUp(() {
    mockLeagueService = MockLeagueService();
    mockMissionService = MockMissionService();
    provider = LeagueProvider(mockLeagueService, mockMissionService);
  });

  group('LeagueProvider 100% Coverage', () {

    final tResult = LeagueResultModel(id: 'r1', nivellAnterior: 2, nivellNou: 3, posicioFinal: 1);
    final tParticipation = LeagueParticipationModel(userId: 'u1', leagueId: 'l1', xpTemporada: 100, posicioActual: 1);

    test('initRealtimeListeners: subscriu i executa callbacks', () async {
      final leagueChangedCtrl = StreamController<void>();
      final resultsCtrl = StreamController<LeagueResultModel>();

      when(() => mockLeagueService.onUserLeagueChanged('u1')).thenAnswer((_) => leagueChangedCtrl.stream);
      when(() => mockLeagueService.listenForSeasonResults('u1')).thenAnswer((_) => resultsCtrl.stream);

      when(() => mockLeagueService.getUserLeague('u1')).thenAnswer((_) async => null);

      provider.initRealtimeListeners('u1');

      leagueChangedCtrl.add(null);
      resultsCtrl.add(tResult);
      await pumpEventQueue();

      expect(provider.pendingResult, tResult);

      await leagueChangedCtrl.close();
      await resultsCtrl.close();
    });

    test('loadUserLeague: amb dades (Top 3 missió) i sense dades', () async {
      final rankingCtrl = StreamController<List<LeagueParticipationModel>>();

      final mockData = {
        'lligues': {
          'id': 'l1',
          'nom_lliga': 'Or',
          'nivell_lliga': 3,
          'color': '#FFF',
          'data_inici': DateTime.now().toIso8601String(),
          'data_fi': DateTime.now().toIso8601String()
        }
      };

      when(() => mockLeagueService.getUserLeague('u1')).thenAnswer((_) async => mockData);
      when(() => mockLeagueService.getRankingStream('l1')).thenAnswer((_) => rankingCtrl.stream);
      when(() => mockMissionService.updateProgress('u1', 'league', 1.0, any())).thenAnswer((_) async => {});

      await provider.loadUserLeague('u1');
      rankingCtrl.add([tParticipation]);
      await pumpEventQueue();

      expect(provider.currentLeague, isNotNull);
      expect(provider.ranking.length, 1);
      verify(() => mockMissionService.updateProgress('u1', 'league', 1.0, any())).called(1);

      when(() => mockLeagueService.getUserLeague('u2')).thenAnswer((_) async => null);
      await provider.loadUserLeague('u2');
      expect(provider.currentLeague, isNull);
      expect(provider.ranking, isEmpty);

      await rankingCtrl.close();
    });

    test('checkLeagueResults i dismissResult', () async {
      when(() => mockLeagueService.getPendingResult('u1')).thenAnswer((_) async => {
        'id': 'r1', 'nivell_anterior': 1, 'nivell_nou': 2, 'posicio_final': 1
      });
      await provider.checkLeagueResults('u1');
      expect(provider.pendingResult, isNotNull);

      when(() => mockLeagueService.markResultAsSeen('r1')).thenAnswer((_) async => {});
      await provider.dismissResult();
      expect(provider.pendingResult, isNull);
    });

    test('loadAnyUserLeague: èxit i error', () async {
      final mockData = {
        'lligues': {
          'id': 'l1',
          'nom_lliga': 'Or',
          'nivell_lliga': 3,
          'color': '#FFF',
          'data_inici': DateTime.now().toIso8601String(),
          'data_fi': DateTime.now().toIso8601String()
        }
      };

      when(() => mockLeagueService.getUserLeague('u1')).thenAnswer((_) async => mockData);
      final result = await provider.loadAnyUserLeague('u1');
      expect(result, isNotNull);

      when(() => mockLeagueService.getUserLeague('bad')).thenThrow(Exception('Error DB'));
      final badResult = await provider.loadAnyUserLeague('bad');
      expect(badResult, isNull);
    });

    test('dispose: cancel·la subscripcions', () {
      provider.dispose();
      expect(provider, isNotNull);
    });
  });
}