import 'package:flutter/material.dart';
import '../../domain/services/social_service.dart';
import '../../domain/models/social_stats_model.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _socialService;

  SocialStats? _stats;

  SocialProvider(this._socialService);

  int get followersCount => _stats?.followersCount ?? 0;
  int get followingCount => _stats?.followingCount ?? 0;
  bool get hasPendingRequests => _stats?.hasPendingRequests ?? false;

  Future<void> refreshSocialStats(String userId) async {
    try {
      _stats = await _socialService.getSocialOverview(userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshSocialStats al Provider: $e");
    }
  }

  Future<void> toggleFollow(String targetId, String privacy) async {
    await _socialService.toggleFollow(targetId, privacy);
    notifyListeners();
  }

  Future<SocialStats> getOtherUserStats(String userId) {
    return _socialService.getSocialOverview(userId);
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() => _socialService.getPendingRequests();
  Future<List<Map<String, dynamic>>> getFollowNotifications() => _socialService.getFollowNotifications();
  Future<void> markNotificationsAsRead() => _socialService.markNotificationsAsRead();
  Future<void> acceptFollowRequest(String reqId, String followerId) => _socialService.acceptFollowRequest(reqId, followerId);
  Future<void> rejectFollowRequest(String reqId) => _socialService.rejectFollowRequest(reqId);
  Future<Map<String, bool>> getFollowStatus(String targetId) => _socialService.getFollowStatus(targetId);
  Future<void> unfollowOrCancel(String targetId, bool isPending) => _socialService.unfollowOrCancel(targetId, isPending);
  Future<void> followUser(String targetId, String privacy) => _socialService.followUser(targetId, privacy);
  Future<List<Map<String, dynamic>>> getFollowersList(String userId) => _socialService.getFollowersList(userId);
  Future<List<Map<String, dynamic>>> getFollowingList(String userId) => _socialService.getFollowingList(userId);
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) => _socialService.searchUsers(query, limit: limit);
  Future<void> removeFollower(String followerId) => _socialService.removeFollower(followerId);
}