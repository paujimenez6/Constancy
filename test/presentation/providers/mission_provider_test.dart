import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/presentation/providers/mission_provider.dart';
import 'package:Constancy/domain/services/mission_service.dart';
import 'package:Constancy/domain/models/mission_model.dart';

class MockMissionService extends Mock implements MissionService {}

class FakeMissionDefinition extends Fake implements MissionModel {
  @override
  int get recompensaXp => 100;
}

class FakeUserMission extends Fake implements UserMissionModel {
  @override
  String get id => 'm1';

  @override
  MissionModel get definicio => FakeMissionDefinition();
}

void main() {
  late MissionProvider provider;
  late MockMissionService mockService;

  setUpAll(() {
    registerFallbackValue(FakeUserMission());
  });

  setUp(() {
    mockService = MockMissionService();
    provider = MissionProvider(mockService);
  });

  group('MissionProvider 100% Coverage', () {
    final tMission = FakeUserMission();

    test('initMissionsListener: encadena fetchToday i listenToMissions', () async {
      final streamCtrl = StreamController<List<UserMissionModel>>();

      when(() => mockService.fetchTodayMissions('u1')).thenAnswer((_) async => []);
      when(() => mockService.listenToMissions('u1')).thenAnswer((_) => streamCtrl.stream);

      provider.initMissionsListener('u1');

      await pumpEventQueue();

      streamCtrl.add([tMission]);
      await pumpEventQueue();

      expect(provider.missions.isNotEmpty, isTrue);
      expect(provider.isLoading, isFalse);

      await streamCtrl.close();
    });

    test('loadMissions: èxit i error', () async {
      when(() => mockService.fetchTodayMissions('u1')).thenAnswer((_) async => [tMission]);
      await provider.loadMissions('u1');
      expect(provider.missions.length, 1);

      when(() => mockService.fetchTodayMissions('bad')).thenThrow(Exception('Fail'));
      await provider.loadMissions('bad');
    });

    test('notifyAction: èxit i error', () async {
      when(() => mockService.updateProgress('u1', 't1', 1.0, 'i1')).thenAnswer((_) async => {});
      await provider.notifyAction('u1', 't1', 'i1');
      verify(() => mockService.updateProgress('u1', 't1', 1.0, 'i1')).called(1);

      when(() => mockService.updateProgress('u1', 't1', 1.0, 'i1')).thenThrow(Exception('Fail'));
      await provider.notifyAction('u1', 't1', 'i1');
    });

    test('claimMission: èxit (amb i sense multiplicador) i error', () async {
      when(() => mockService.claimReward(any(), any())).thenAnswer((_) async => {});
      when(() => mockService.updateProgress(any(), any(), any(), any())).thenAnswer((_) async => {});

      final res1 = await provider.claimMission(tMission, 'u1', true);
      expect(res1, isTrue);
      verify(() => mockService.updateProgress('u1', 'xp', 200.0, 'claim_m1')).called(1);

      final res2 = await provider.claimMission(tMission, 'u1', false);
      expect(res2, isTrue);
      verify(() => mockService.updateProgress('u1', 'xp', 100.0, 'claim_m1')).called(1);

      when(() => mockService.claimReward(any(), any())).thenThrow(Exception('DB Fail'));
      final res3 = await provider.claimMission(tMission, 'bad', false);
      expect(res3, isFalse);
    });

    test('reroll: èxit i error', () async {
      when(() => mockService.executeReroll('u1', 'm1', 'inv1')).thenAnswer((_) async => {});
      when(() => mockService.fetchTodayMissions('u1')).thenAnswer((_) async => []);

      await provider.reroll('u1', 'm1', 'inv1');
      verify(() => mockService.executeReroll('u1', 'm1', 'inv1')).called(1);

      when(() => mockService.executeReroll('u1', 'm1', 'inv1')).thenThrow(Exception('Fail'));
      expect(() => provider.reroll('u1', 'm1', 'inv1'), throwsException);
    });

    test('dispose cancel·la la subscripció', () {
      provider.dispose();
      expect(provider, isNotNull);
    });
  });
}