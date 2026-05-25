import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/mission_model.dart';

void main() {
  group('MissionModel Test', () {
    test('fromJson parseja correctament un JSON complert', () {
      final json = {
        'id': 'm1',
        'titol_clau': 't_test',
        'desc_clau': 'd_test',
        'recompensa_xp': 100,
        'recompensa_monedes': 50,
        'objectiu': 10.0,
        'tipus': 'diari'
      };

      final mission = MissionModel.fromJson(json);

      expect(mission.id, 'm1');
      expect(mission.titolClau, 't_test');
      expect(mission.recompensaXp, 100);
      expect(mission.objectiu, 10.0);
    });
  });

  group('UserMissionModel Test', () {
    test('fromJson parseja correctament un JSON complert i calcula percentatge', () {
      final json = {
        'id': 'um1',
        'progres_actual': 25.0,
        'completada': false,
        'reclamada': false,
        'missions_definicions': {
          'id': 'm1',
          'titol_clau': 't1',
          'desc_clau': 'd1',
          'recompensa_xp': 10,
          'recompensa_monedes': 5,
          'objectiu': 100.0,
          'tipus': 'test'
        }
      };

      final userMission = UserMissionModel.fromJson(json);

      expect(userMission.id, 'um1');
      expect(userMission.progresActual, 25.0);
      expect(userMission.definicio.id, 'm1');

      expect(userMission.percentatge, 0.25);
    });

    test('percentatge fa clamp a 1.0 si es supera l\'objectiu', () {
      final def = MissionModel(
          id: '1', titolClau: 't', descripcioClau: 'd',
          recompensaXp: 10, recompensaMonedes: 10,
          objectiu: 100.0, tipus: 'x'
      );

      final overMission = UserMissionModel(
          id: '2', progresActual: 150.0, completada: true, reclamada: false, definicio: def
      );

      expect(overMission.percentatge, 1.0);
    });
  });
}