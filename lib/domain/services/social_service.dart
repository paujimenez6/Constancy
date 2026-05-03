import '../../persistence/repositories/social_repository.dart';
import '../models/social_stats_model.dart';

class SocialService {
  final SocialRepository _socialRepository;

  SocialService(this._socialRepository);

  Future<SocialStats> getSocialOverview(String userId) async {
    final results = await Future.wait([
      _socialRepository.getFollowersCount(userId),
      _socialRepository.getFollowingCount(userId),
      _socialRepository.checkPendingRequests(),
    ]);

    return SocialStats(
      followersCount: results[0] as int,
      followingCount: results[1] as int,
      hasPendingRequests: results[2] as bool,
    );
  }

  Future<Map<String, bool>> getFollowStatus(String targetUserId) =>
      _socialRepository.getFollowStatus(targetUserId);

  Future<void> followUser(String targetUserId, String privacy) =>
      _socialRepository.followUser(targetUserId, privacy);

  Future<void> unfollowOrCancel(String targetUserId, bool isPending) =>
      _socialRepository.unfollowOrCancel(targetUserId, isPending);

  Future<void> removeFollower(String followerId) =>
      _socialRepository.removeFollower(followerId);

  Future<List<Map<String, dynamic>>> getPendingRequests() =>
      _socialRepository.getPendingRequests();

  Future<List<Map<String, dynamic>>> getFollowNotifications() =>
      _socialRepository.getFollowNotifications();

  Future<void> markNotificationsAsRead() =>
      _socialRepository.markNotificationsAsRead();

  Future<void> acceptFollowRequest(String requestId, String followerId) =>
      _socialRepository.acceptFollowRequest(requestId, followerId);

  Future<void> rejectFollowRequest(String requestId) =>
      _socialRepository.rejectFollowRequest(requestId);

  Future<void> toggleFollow(String targetId, String privacy) async {
    final status = await _socialRepository.getFollowStatus(targetId);
    final bool isFollowing = status['isFollowing'] ?? false;
    final bool isPending = status['isPending'] ?? false;

    if (isFollowing || isPending) {
      await _socialRepository.unfollowOrCancel(targetId, isPending);
    } else {
      await _socialRepository.followUser(targetId, privacy);
    }
  }

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) =>
      _socialRepository.getFollowersList(userId);

  Future<List<Map<String, dynamic>>> getFollowingList(String userId) =>
      _socialRepository.getFollowingList(userId);

  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) =>
      _socialRepository.searchUsers(query, limit: limit);
}