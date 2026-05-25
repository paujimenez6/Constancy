import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/domain/services/league_service.dart';
import 'package:Constancy/persistence/repositories/league_repository.dart';
import 'package:Constancy/domain/models/league_model.dart';

class MockLeagueRepository extends Mock implements LeagueRepository {}

void main() {
  late LeagueService service;
  late MockLeagueRepository mockRepository;

  setUp(() {
    mockRepository = MockLeagueRepository();
    service = LeagueService(mockRepository);
  });

  group('LeagueService Test (100% Coverage)', () {
    test('getRanking mapeja correctament el JSON', () async {
      final mockData = [{'user_id': 'u1', 'league_id': 'l1', 'xp_temporada': 10}];
      when(() => mockRepository.getLeagueRanking('l1')).thenAnswer((_) async => mockData);

      final result = await service.getRanking('l1');
      expect(result.first.xpTemporada, 10);
    });

    test('getRankingStream retorna el stream correctament', () {
      final mockStream = Stream.value([{'user_id': 'u1', 'league_id': 'l1', 'xp_temporada': 10}]);
      when(() => mockRepository.listenToRanking('l1')).thenAnswer((_) => mockStream);

      expect(service.getRankingStream('l1'), emits(isA<List<LeagueParticipationModel>>()));
    });

    test('getPendingResult crida al repo', () async {
      when(() => mockRepository.getPendingResult('u1')).thenAnswer((_) async => {'id': 'r1'});
      final result = await service.getPendingResult('u1');
      expect(result, isNotNull);
      verify(() => mockRepository.getPendingResult('u1')).called(1);
    });

    test('listenForSeasonResults: retorna null si no hi ha pendents', () {
      final mockStream = Stream.value([
        {'id': 'r2', 'vists': true, 'nivell_anterior': 1, 'nivell_nou': 2, 'posicio_final': 1}
      ]);
      when(() => mockRepository.listenToNewResults('u1')).thenAnswer((_) => mockStream);

      expect(service.listenForSeasonResults('u1'), emits(isNull));
    });

    test('listenForSeasonResults: retorna model si hi ha pendents', () {
      final mockStream = Stream.value([
        {'id': 'r1', 'vists': false, 'nivell_anterior': 1, 'nivell_nou': 2, 'posicio_final': 1}
      ]);
      when(() => mockRepository.listenToNewResults('u1')).thenAnswer((_) => mockStream);

      expect(service.listenForSeasonResults('u1'), emits(isA<LeagueResultModel>()));
    });

    test('Altres mètodes', () async {
      when(() => mockRepository.getCurrentUserLeague('u1')).thenAnswer((_) async => {});
      when(() => mockRepository.markResultAsSeen('r1')).thenAnswer((_) async => {});
      when(() => mockRepository.listenToUserParticipation('u1')).thenAnswer((_) => const Stream.empty());

      await service.getUserLeague('u1');
      await service.markResultAsSeen('r1');
      service.onUserLeagueChanged('u1').listen((_) {});

      verify(() => mockRepository.getCurrentUserLeague('u1')).called(1);
      verify(() => mockRepository.markResultAsSeen('r1')).called(1);
      verify(() => mockRepository.listenToUserParticipation('u1')).called(1);
    });
  });
}