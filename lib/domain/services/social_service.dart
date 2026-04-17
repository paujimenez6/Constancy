import '../../persistence/repositories/social_repository.dart';

class SocialService {
  final SocialRepository _socialRepository;

  SocialService(this._socialRepository);

  Future<int> getFollowersCount(String userId) => _socialRepository.getFollowersCount(userId);

  Future<int> getFollowingCount(String userId) => _socialRepository.getFollowingCount(userId);

  Future<bool> checkPendingRequests() => _socialRepository.checkPendingRequests();

  Future<List<Map<String, dynamic>>> getPendingRequests() => _socialRepository.getPendingRequests();

  Future<List<Map<String, dynamic>>> getFollowNotifications() => _socialRepository.getFollowNotifications();

  Future<void> markNotificationsAsRead() => _socialRepository.markNotificationsAsRead();

  Future<void> acceptFollowRequest(String requestId, String followerId) => _socialRepository.acceptFollowRequest(requestId, followerId);

  Future<void> rejectFollowRequest(String requestId) => _socialRepository.rejectFollowRequest(requestId);

  Future<Map<String, bool>> getFollowStatus(String targetUserId) => _socialRepository.getFollowStatus(targetUserId);

  Future<void> followUser(String targetUserId, String privacy) => _socialRepository.followUser(targetUserId, privacy);

  Future<void> unfollowOrCancel(String targetUserId, bool isPending) => _socialRepository.unfollowOrCancel(targetUserId, isPending);

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) => _socialRepository.getFollowersList(userId);

  Future<List<Map<String, dynamic>>> getFollowingList(String userId) => _socialRepository.getFollowingList(userId);

  Future<void> removeFollower(String followerId) => _socialRepository.removeFollower(followerId);

  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) => _socialRepository.searchUsers(query, limit: limit);
}