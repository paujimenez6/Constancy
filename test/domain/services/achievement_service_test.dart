import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Constancy/domain/services/achievement_service.dart';
import 'package:Constancy/persistence/repositories/achievement_repository.dart';

class MockAchievementRepository extends Mock implements AchievementRepository {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late AchievementService service;
  late MockAchievementRepository mockRepository;

  setUp(() {
    mockRepository = MockAchievementRepository();
    service = AchievementService(mockRepository);
  });

  group('AchievementService Test', () {

    test('generateRandomXP retorna valors en el rang esperat (10-100 i múltiples de 5)', () {
      for (int i = 0; i < 50; i++) {
        final xp = service.generateRandomXP();
        expect(xp, greaterThanOrEqualTo(10));
        expect(xp, lessThanOrEqualTo(100));
        expect(xp % 5, equals(0));
      }
    });

    test('Tots els mètodes criden al repository correctament', () async {
      when(() => mockRepository.getUserAchievements('u1')).thenAnswer((_) async => []);
      when(() => mockRepository.subscribeToAchievementChanges('u1', any())).thenReturn(MockRealtimeChannel());
      when(() => mockRepository.updateProgress('u1', 'c', 1)).thenAnswer((_) async {});
      when(() => mockRepository.setAbsoluteProgress('u1', 'c', 10)).thenAnswer((_) async {});
      when(() => mockRepository.markAsClaimed('a1', 'u1', 50)).thenAnswer((_) async => true);
      when(() => mockRepository.syncPerfectDay('u1', any(), true)).thenAnswer((_) async {});

      await service.getUserAchievements('u1');
      service.subscribeToAchievementChanges('u1', () {});
      await service.updateProgress('u1', 'c', 1);
      await service.setAbsoluteProgress('u1', 'c', 10);
      await service.markAsClaimed('a1', 'u1', 50);
      await service.syncPerfectDay('u1', DateTime.now(), true);

      verify(() => mockRepository.getUserAchievements('u1')).called(1);
      verify(() => mockRepository.subscribeToAchievementChanges('u1', any())).called(1);
      verify(() => mockRepository.updateProgress('u1', 'c', 1)).called(1);
      verify(() => mockRepository.setAbsoluteProgress('u1', 'c', 10)).called(1);
      verify(() => mockRepository.markAsClaimed('a1', 'u1', 50)).called(1);
      verify(() => mockRepository.syncPerfectDay('u1', any(), true)).called(1);
    });
  });
}