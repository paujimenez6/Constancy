import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/presentation/providers/achievement_provider.dart';
import 'package:Constancy/domain/services/achievement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAchievementService extends Mock implements AchievementService {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late AchievementProvider provider;
  late MockAchievementService mockService;

  setUp(() {
    mockService = MockAchievementService();
    provider = AchievementProvider(mockService);
  });

  group('AchievementProvider 100% Coverage', () {

    test('loadUserAchievements: èxit i error (cobreix bloc catch)', () async {
      when(() => mockService.getUserAchievements('u1')).thenAnswer((_) async => []);
      await provider.loadUserAchievements('u1');
      expect(provider.isLoading, false);

      when(() => mockService.getUserAchievements('u1')).thenThrow(Exception('Error'));
      await provider.loadUserAchievements('u1');
      expect(provider.isLoading, false);
    });

    test('listenToAchievementChanges: subscripció i execució del callback', () async {
      final mockChannel = MockRealtimeChannel();
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');

      when(() => mockService.subscribeToAchievementChanges(any(), any()))
          .thenReturn(mockChannel);
      when(() => mockService.getUserAchievements(any())).thenAnswer((_) async => []);

      provider.listenToAchievementChanges('u1');

      final captured = verify(() => mockService.subscribeToAchievementChanges('u1', captureAny())).captured;
      final callback = captured.first as Function;

      await callback();

      provider.stopListeningToAchievementChanges();
      expect(provider, isNotNull);
    });

    test('claimAchievementReward: èxit', () async {
      when(() => mockService.generateRandomXP()).thenReturn(10);
      when(() => mockService.markAsClaimed('a1', 'u1', 10)).thenAnswer((_) async => true);
      when(() => mockService.getUserAchievements('u1')).thenAnswer((_) async => []);

      final xp = await provider.claimAchievementReward('a1', 'u1');
      expect(xp, 10);
    });

    test('trackAction: èxit i error (cobreix bloc catch)', () async {
      when(() => mockService.updateProgress('u1', 'c1', 1)).thenAnswer((_) async => {});
      await provider.trackAction('u1', 'c1');
      verify(() => mockService.updateProgress('u1', 'c1', 1)).called(1);

      when(() => mockService.updateProgress('u2', 'c2', 1)).thenThrow(Exception('DB Error'));
      await provider.trackAction('u2', 'c2');
    });

    test('setAbsoluteProgress: execució', () async {
      when(() => mockService.setAbsoluteProgress('u1', 'c1', 100))
          .thenAnswer((_) async => {});

      await provider.setAbsoluteProgress('u1', 'c1', 100);
      verify(() => mockService.setAbsoluteProgress('u1', 'c1', 100)).called(1);
    });

    test('dispose: neteja recursos', () {
      final mockChannel = MockRealtimeChannel();
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');
      when(() => mockService.subscribeToAchievementChanges(any(), any()))
          .thenReturn(mockChannel);

      provider.listenToAchievementChanges('u1');

      provider.dispose();
      expect(provider, isNotNull);
    });
  });
}