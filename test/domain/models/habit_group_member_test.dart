import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/habit_group_member_model.dart';

void main() {
  group('HabitGroupMember Test', () {
    test('fromJson parseja correctament les dades', () {
      final json = {
        'user_id': 'user123',
        'nickname': 'Pau',
        'imatge_perfil': 'url_foto',
        'progres_acumulat': 100.5,
        'progres_dia': 10.0,
        'es_administrador': true,
      };

      final member = HabitGroupMember.fromJson(json);

      expect(member.userId, 'user123');
      expect(member.nickname, 'Pau');
      expect(member.imatgePerfil, 'url_foto');
      expect(member.progresAcumulat, 100.5);
      expect(member.progresAvui, 10.0);
      expect(member.esAdministrador, true);
    });

    test('fromJson maneja valors nuls/per defecte', () {
      final json = {'user_id': 'user123'};
      final member = HabitGroupMember.fromJson(json);

      expect(member.nickname, 'Usuari');
      expect(member.progresAcumulat, 0.0);
      expect(member.esAdministrador, false);
    });
  });
}