import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/domain/services/social_service.dart';
import 'package:Constancy/persistence/repositories/social_repository.dart';

class MockSocialRepository extends Mock implements SocialRepository {}

void main() {
  late SocialService service;
  late MockSocialRepository mockRepository;

  setUp(() {
    mockRepository = MockSocialRepository();
    service = SocialService(mockRepository);
  });

  group('SocialService Full Coverage (100%)', () {
    test('getSocialOverview combina Future.wait correctament', () async {
      when(() => mockRepository.getFollowersCount('u1')).thenAnswer((_) async => 10);
      when(() => mockRepository.getFollowingCount('u1')).thenAnswer((_) async => 5);
      when(() => mockRepository.checkPendingRequests()).thenAnswer((_) async => true);

      final stats = await service.getSocialOverview('u1');
      expect(stats.followersCount, 10);
      expect(stats.hasPendingRequests, isTrue);
    });

    test('Mètodes directes (getFollowStatus, followUser, unfollowOrCancel)', () async {
      when(() => mockRepository.getFollowStatus('u2')).thenAnswer((_) async => {'isFollowing': false});
      when(() => mockRepository.followUser('u2', 'privat')).thenAnswer((_) async => {});
      when(() => mockRepository.unfollowOrCancel('u2', false)).thenAnswer((_) async => {});

      final status = await service.getFollowStatus('u2');
      await service.followUser('u2', 'privat');
      await service.unfollowOrCancel('u2', false);

      expect(status['isFollowing'], isFalse);
      verify(() => mockRepository.followUser('u2', 'privat')).called(1);
    });

    test('toggleFollow: ambdós casos (isFollowing i isPending)', () async {
      when(() => mockRepository.getFollowStatus('u_fol')).thenAnswer((_) async => {'isFollowing': true, 'isPending': false});
      when(() => mockRepository.unfollowOrCancel('u_fol', false)).thenAnswer((_) async => {});

      await service.toggleFollow('u_fol', 'privat');
      verify(() => mockRepository.unfollowOrCancel('u_fol', false)).called(1);

      when(() => mockRepository.getFollowStatus('u_pen')).thenAnswer((_) async => {'isFollowing': false, 'isPending': true});
      when(() => mockRepository.unfollowOrCancel('u_pen', true)).thenAnswer((_) async => {});

      await service.toggleFollow('u_pen', 'privat');
      verify(() => mockRepository.unfollowOrCancel('u_pen', true)).called(1);

      when(() => mockRepository.getFollowStatus('u_none')).thenAnswer((_) async => {'isFollowing': false, 'isPending': false});
      when(() => mockRepository.followUser('u_none', 'privat')).thenAnswer((_) async => {});

      await service.toggleFollow('u_none', 'privat');
      verify(() => mockRepository.followUser('u_none', 'privat')).called(1);
    });

    test('Resta de mètodes CRUD', () async {
      when(() => mockRepository.currentUserId).thenReturn('u1');
      when(() => mockRepository.removeFollower(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getPendingRequests()).thenAnswer((_) async => []);
      when(() => mockRepository.getFollowNotifications()).thenAnswer((_) async => []);
      when(() => mockRepository.markNotificationsAsRead()).thenAnswer((_) async => {});
      when(() => mockRepository.acceptFollowRequest(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.rejectFollowRequest(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getFollowersList(any())).thenAnswer((_) async => []);
      when(() => mockRepository.getFollowingList(any())).thenAnswer((_) async => []);
      when(() => mockRepository.searchUsers(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
      when(() => mockRepository.getUserById(any())).thenAnswer((_) async => null);

      expect(service.currentUserId, 'u1');
      await service.removeFollower('f1');
      await service.getPendingRequests();
      await service.getFollowNotifications();
      await service.markNotificationsAsRead();
      await service.acceptFollowRequest('r1', 'f1');
      await service.rejectFollowRequest('r1');
      await service.getFollowersList('u1');
      await service.getFollowingList('u1');
      await service.searchUsers('query');
      await service.getUserById('u1');
    });
  });
}