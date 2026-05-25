import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/league_model.dart';

void main() {
  group('LeagueModel Test', () {
    final mockStrings = _MockStrings();
    final now = DateTime.now();

    test('fromJson parseja correctament', () {
      final json = {
        'id': 'l1',
        'nom_lliga': 'Lliga Pro',
        'nivell_lliga': 3,
        'color': '#FF0000',
        'data_inici': '2026-05-01T00:00:00Z',
        'data_fi': '2026-05-31T23:59:59Z',
      };
      final league = LeagueModel.fromJson(json);
      expect(league.id, 'l1');
      expect(league.nivellLliga, 3);
    });

    test('getLocalizedName i getLocalizedLevelName cobreixen tots els nivells', () {
      final league = LeagueModel(id: '1', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now);

      expect(league.getLocalizedName(mockStrings), 'Bronze');

      expect(LeagueModel.getLocalizedLevelName(1, mockStrings), 'Bronze');
      expect(LeagueModel.getLocalizedLevelName(2, mockStrings), 'Silver');
      expect(LeagueModel.getLocalizedLevelName(3, mockStrings), 'Gold');
      expect(LeagueModel.getLocalizedLevelName(4, mockStrings), 'Ruby');
      expect(LeagueModel.getLocalizedLevelName(5, mockStrings), 'Emerald');
      expect(LeagueModel.getLocalizedLevelName(6, mockStrings), 'Diamond');
      expect(LeagueModel.getLocalizedLevelName(99, mockStrings, fallback: 'Desconegut'), 'Desconegut');
    });

    test('Getters de nivell funcionen', () {
      final maxLliga = LeagueModel(id: '1', nomLliga: 'X', nivellLliga: 6, color: 'X', dataInici: now, dataFi: now);
      final minLliga = LeagueModel(id: '2', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now);

      expect(maxLliga.isMaxLevel, isTrue);
      expect(minLliga.isMinLevel, isTrue);
    });

    test('getTimeRemaining cobreix totes les branques', () {
      final lligaPassada = LeagueModel(id: '1', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now.subtract(const Duration(days: 1)));
      expect(lligaPassada.getTimeRemaining(mockStrings), 'Finished');

      final lligaDies = LeagueModel(id: '2', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now.add(const Duration(days: 2, hours: 2)));
      expect(lligaDies.getTimeRemaining(mockStrings), contains('2 dies'));

      final lligaHores = LeagueModel(id: '3', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now.add(const Duration(hours: 3, minutes: 5)));
      expect(lligaHores.getTimeRemaining(mockStrings), contains('3 hores'));

      final lligaMinuts = LeagueModel(id: '4', nomLliga: 'X', nivellLliga: 1, color: 'X', dataInici: now, dataFi: now.add(const Duration(minutes: 10, seconds: 30)));
      expect(lligaMinuts.getTimeRemaining(mockStrings), anyOf(contains('10 minuts'), contains('9 minuts')));
    });
  });

  group('LeagueParticipationModel Test', () {
    test('fromJson parseja correctament amb perfil', () {
      final json = {
        'user_id': 'u1',
        'league_id': 'l1',
        'xp_temporada': 100,
        'posicio_actual': 2,
        'profiles': {'nickname': 'Pau', 'punts_xp': 500}
      };
      final part = LeagueParticipationModel.fromJson(json);
      expect(part.nickname, 'Pau');
      expect(part.puntsXP, 500);
    });

    test('fromJson parseja correctament sense perfil', () {
      final json = {'user_id': 'u1', 'league_id': 'l1'};
      final part = LeagueParticipationModel.fromJson(json);
      expect(part.nickname, isNull);
    });
  });

  group('LeagueResultModel Test', () {
    test('fromJson i Type calculen correctament', () {
      final json = {'id': 'r1', 'nivell_anterior': 1, 'nivell_nou': 2, 'posicio_final': 1};
      final res = LeagueResultModel.fromJson(json);

      expect(res.id, 'r1');
      expect(res.type, LeagueResultType.promoted);

      final demoted = LeagueResultModel(id: '2', nivellAnterior: 2, nivellNou: 1, posicioFinal: 10);
      expect(demoted.type, LeagueResultType.demoted);

      final stayed = LeagueResultModel(id: '3', nivellAnterior: 1, nivellNou: 1, posicioFinal: 5);
      expect(stayed.type, LeagueResultType.stayed);
    });
  });
}

class _MockStrings {
  String get leagueBronze => 'Bronze';
  String get leagueSilver => 'Silver';
  String get leagueGold => 'Gold';
  String get leagueRuby => 'Ruby';
  String get leagueEmerald => 'Emerald';
  String get leagueDiamond => 'Diamond';
  String get leagueResultFinished => 'Finished';
  String timeLeftDays(int days) => '$days dies';
  String timeLeftHoursMinutes(int h, int m) => '$h hores $m minuts';
  String timeLeftMinutes(int m) => '$m minuts';
}