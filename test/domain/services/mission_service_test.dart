import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/domain/services/mission_service.dart';
import 'package:Constancy/persistence/repositories/mission_repository.dart';
import 'package:Constancy/domain/models/mission_model.dart';

class MockMissionRepository extends Mock implements MissionRepository {}

void main() {
  late MissionService service;
  late MockMissionRepository mockRepository;

  setUp(() {
    mockRepository = MockMissionRepository();
    service = MissionService(mockRepository);
  });

  group('MissionService Coverage', () {
    final tMissionDef = MissionModel(
        id: 'd1', titolClau: 't', descripcioClau: 'd',
        recompensaXp: 10, recompensaMonedes: 5, objectiu: 10, tipus: 'test'
    );
    final tUserMission = UserMissionModel(
        id: 'um1', progresActual: 10, completada: true,
        reclamada: false, definicio: tMissionDef
    );

    test('fetchTodayMissions assigna i retorna missions', () async {
      when(() => mockRepository.assignarMissionsDiaries('u1')).thenAnswer((_) async => {});
      when(() => mockRepository.getUserMissions('u1')).thenAnswer((_) async => [
        {
          'id': 'um1',
          'progres_actual': 10,
          'completada': true,
          'reclamada': false,
          'missions_definicions': {
            'id': 'd1', 'titol_clau': 't', 'desc_clau': 'd',
            'recompensa_xp': 10, 'recompensa_monedes': 5,
            'objectiu': 10.0, 'tipus': 'test'
          }
        }
      ]);

      final result = await service.fetchTodayMissions('u1');
      expect(result.length, 1);
      verify(() => mockRepository.assignarMissionsDiaries('u1')).called(1);
    });

    test('updateProgress crida al repositori', () async {
      when(() => mockRepository.incrementMissionProgress('u1', 'test', 1.0, 'i1')).thenAnswer((_) async => {});
      await service.updateProgress('u1', 'test', 1.0, 'i1');
      verify(() => mockRepository.incrementMissionProgress('u1', 'test', 1.0, 'i1')).called(1);
    });

    test('claimReward: exit i excepcions', () async {
      when(() => mockRepository.claimMissionReward('um1', 'u1')).thenAnswer((_) async => {});

      await service.claimReward(tUserMission, 'u1');
      verify(() => mockRepository.claimMissionReward('um1', 'u1')).called(1);

      final missionNoCompletada = UserMissionModel(
          id: tUserMission.id,
          progresActual: tUserMission.progresActual,
          completada: false,
          reclamada: tUserMission.reclamada,
          definicio: tUserMission.definicio
      );

      expect(() => service.claimReward(missionNoCompletada, 'u1'), throwsException);
    });

    test('listenToMissions retorna stream', () {
      when(() => mockRepository.listenToUserMissions('u1')).thenAnswer((_) => Stream.value([
        {
          'id': 'um1', 'progres_actual': 10, 'completada': true, 'reclamada': false,
          'missions_definicions': {
            'id': 'd1', 'titol_clau': 't', 'desc_clau': 'd',
            'recompensa_xp': 10, 'recompensa_monedes': 5,
            'objectiu': 10.0, 'tipus': 'test'
          }
        }
      ]));

      expect(service.listenToMissions('u1'), emits(isA<List<UserMissionModel>>()));
    });

    test('executeReroll crida al repositori', () async {
      when(() => mockRepository.rerollMission('u1', 'um1', 'i1')).thenAnswer((_) async => {});
      await service.executeReroll('u1', 'um1', 'i1');
      verify(() => mockRepository.rerollMission('u1', 'um1', 'i1')).called(1);
    });
  });
}