import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/habit_record_model.dart';

void main() {
  group('HabitRecordModel Test', () {
    test('fromJson parseja correctament', () {
      final json = {
        'id': 'rec1',
        'habit_id': 'hab1',
        'user_id': 'user1',
        'data_registre': '2026-05-21',
        'completat': true,
        'valor_progres': 5.5,
        'created_at': '2026-05-21T10:00:00Z',
        'updated_at': '2026-05-21T12:00:00Z',
      };

      final record = HabitRecordModel.fromJson(json);

      expect(record.id, 'rec1');
      expect(record.completat, true);
      expect(record.valorProgres, 5.5);
    });

    test('copyWith actualitza correctament', () {
      final record = HabitRecordModel(
        id: '1', habitId: 'h1', userId: 'u1', dataRegistre: DateTime.now(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );

      final updated = record.copyWith(completat: true, valorProgres: 10.0);

      expect(updated.completat, true);
      expect(updated.valorProgres, 10.0);
      expect(updated.id, record.id);
    });
  });
}