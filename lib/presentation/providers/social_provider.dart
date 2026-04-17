import 'package:flutter/material.dart';
import '../../domain/services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _socialService;

  int _followersCount = 0;
  int _followingCount = 0;
  bool _hasPendingRequests = false;

  SocialProvider(this._socialService);

  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  bool get hasPendingRequests => _hasPendingRequests;

  Future<void> refreshSocialStats(String userId) async {
    try {
      final results = await Future.wait([
        _socialService.getFollowersCount(userId),
        _socialService.getFollowingCount(userId),
        _socialService.checkPendingRequests(),
      ]);

      _followersCount = results[0] as int;
      _followingCount = results[1] as int;
      _hasPendingRequests = results[2] as bool;

      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshSocialStats: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() => _socialService.getPendingRequests();

  Future<List<Map<String, dynamic>>> getFollowNotifications() => _socialService.getFollowNotifications();

  Future<void> markNotificationsAsRead() => _socialService.markNotificationsAsRead();

  Future<void> acceptFollowRequest(String reqId, String followerId) => _socialService.acceptFollowRequest(reqId, followerId);

  Future<void> rejectFollowRequest(String reqId) => _socialService.rejectFollowRequest(reqId);

  Future<Map<String, bool>> getFollowStatus(String targetId) => _socialService.getFollowStatus(targetId);

  Future<void> unfollowOrCancel(String targetId, bool isPending) => _socialService.unfollowOrCancel(targetId, isPending);

  Future<void> followUser(String targetId, String privacy) => _socialService.followUser(targetId, privacy);

  Future<int> getFollowersCount(String userId) => _socialService.getFollowersCount(userId);

  Future<int> getFollowingCount(String userId) => _socialService.getFollowingCount(userId);

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) => _socialService.getFollowersList(userId);

  Future<List<Map<String, dynamic>>> getFollowingList(String userId) => _socialService.getFollowingList(userId);

  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) => _socialService.searchUsers(query, limit: limit);

  Future<void> removeFollower(String followerId) => _socialService.removeFollower(followerId);
}