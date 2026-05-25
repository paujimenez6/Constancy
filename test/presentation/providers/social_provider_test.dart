import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/domain/services/social_service.dart';
import 'package:Constancy/domain/services/mission_service.dart';
import 'package:Constancy/domain/services/achievement_service.dart';
import 'package:Constancy/domain/models/social_stats_model.dart';

class MockSocialService extends Mock implements SocialService {}
class MockMissionService extends Mock implements MissionService {}
class MockAchievementService extends Mock implements AchievementService {}
class MockSocialStats extends Mock implements SocialStats {}

void main() {
  late SocialProvider provider;
  late MockSocialService mockSocialService;
  late MockMissionService mockMissionService;
  late MockAchievementService mockAchievementService;

  setUp(() {
    mockSocialService = MockSocialService();
    mockMissionService = MockMissionService();
    mockAchievementService = MockAchievementService();
    provider = SocialProvider(mockSocialService, mockMissionService, mockAchievementService);

    when(() => mockSocialService.currentUserId).thenReturn('u1');
  });

  group('SocialProvider 100% Coverage', () {
    final tStats = MockSocialStats();

    test('Getters inicials retornen 0 o false', () {
      expect(provider.followersCount, 0);
      expect(provider.followingCount, 0);
      expect(provider.hasPendingRequests, false);
    });

    test('refreshSocialStats: èxit i error', () async {
      when(() => tStats.followingCount).thenReturn(5);
      when(() => mockSocialService.getSocialOverview('u1')).thenAnswer((_) async => tStats);
      when(() => mockAchievementService.setAbsoluteProgress('u1', 'seguirAmics10', 5)).thenAnswer((_) async => {});

      await provider.refreshSocialStats('u1');
      expect(provider.followingCount, 5);
      verify(() => mockAchievementService.setAbsoluteProgress('u1', 'seguirAmics10', 5)).called(1);

      when(() => mockSocialService.getSocialOverview('bad')).thenThrow(Exception('DB Error'));
      await provider.refreshSocialStats('bad');
    });

    test('toggleFollow: lògica wasNotFollowing', () async {
      when(() => mockSocialService.getFollowStatus('t1')).thenAnswer((_) async => {'isFollowing': false, 'isPending': false});
      when(() => mockSocialService.toggleFollow('t1', 'public')).thenAnswer((_) async => {});
      when(() => mockMissionService.updateProgress('u1', 'social', 1.0, 't1')).thenAnswer((_) async => {});
      when(() => mockSocialService.getSocialOverview('u1')).thenAnswer((_) async => tStats);

      await provider.toggleFollow('t1', 'public');
      verify(() => mockMissionService.updateProgress('u1', 'social', 1.0, 't1')).called(1);
    });

    test('toggleFollow: wasNotFollowing és false', () async {
      when(() => mockSocialService.getFollowStatus('t1')).thenAnswer((_) async => {'isFollowing': true, 'isPending': false});
      when(() => mockSocialService.toggleFollow('t1', 'public')).thenAnswer((_) async => {});
      when(() => mockSocialService.getSocialOverview('u1')).thenAnswer((_) async => tStats);

      await provider.toggleFollow('t1', 'public');
      verifyNever(() => mockMissionService.updateProgress(any(), any(), any(), any()));
    });

    test('toggleFollow: catch error', () async {
      when(() => mockSocialService.getFollowStatus('t1')).thenThrow(Exception('Fail'));
      expect(() => provider.toggleFollow('t1', 'public'), throwsException);
    });

    test('Passthrough methods (CRUD Social)', () async {
      when(() => mockSocialService.getSocialOverview('u1')).thenAnswer((_) async => tStats);
      when(() => mockSocialService.getUserById('u1')).thenAnswer((_) async => null);
      when(() => mockSocialService.acceptFollowRequest('r1', 'f1')).thenAnswer((_) async => {});
      when(() => mockSocialService.unfollowOrCancel('t1', true)).thenAnswer((_) async => {});
      when(() => mockSocialService.removeFollower('f1')).thenAnswer((_) async => {});
      when(() => mockSocialService.getPendingRequests()).thenAnswer((_) async => []);
      when(() => mockSocialService.getFollowNotifications()).thenAnswer((_) async => []);
      when(() => mockSocialService.markNotificationsAsRead()).thenAnswer((_) async => {});
      when(() => mockSocialService.rejectFollowRequest('r1')).thenAnswer((_) async => {});
      when(() => mockSocialService.getFollowStatus('t1')).thenAnswer((_) async => {'isFollowing': true});
      when(() => mockSocialService.followUser('t1', 'public')).thenAnswer((_) async => {});
      when(() => mockSocialService.getFollowersList('u1')).thenAnswer((_) async => []);
      when(() => mockSocialService.getFollowingList('u1')).thenAnswer((_) async => []);
      when(() => mockSocialService.searchUsers('q')).thenAnswer((_) async => []);

      await provider.getOtherUserStats('u1');
      await provider.getUserById('u1');
      await provider.acceptFollowRequest('r1', 'f1');
      await provider.unfollowOrCancel('t1', true);
      await provider.removeFollower('f1');
      await provider.getPendingRequests();
      await provider.getFollowNotifications();
      await provider.markNotificationsAsRead();
      await provider.rejectFollowRequest('r1');
      await provider.getFollowStatus('t1');
      await provider.followUser('t1', 'public');
      await provider.getFollowersList('u1');
      await provider.getFollowingList('u1');
      await provider.searchUsers('q');
    });
  });
}