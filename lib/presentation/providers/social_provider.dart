import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/social_service.dart';
import '../../domain/services/mission_service.dart';
import '../../domain/models/social_stats_model.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _socialService;
  final MissionService _missionService;
  final AchievementService _achievementService;

  SocialStats? _stats;

  SocialProvider(this._socialService, this._missionService, this._achievementService);

  int get followersCount => _stats?.followersCount ?? 0;
  int get followingCount => _stats?.followingCount ?? 0;
  bool get hasPendingRequests => _stats?.hasPendingRequests ?? false;

  Future<void> refreshSocialStats(String userId) async {
    try {
      _stats = await _socialService.getSocialOverview(userId);
      final myId = _socialService.currentUserId;

      if (userId == myId && _stats != null) {
        await _achievementService.setAbsoluteProgress(myId!, 'seguirAmics10', _stats!.followingCount);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshSocialStats al Provider: $e");
    }
  }

  Future<void> toggleFollow(String targetId, String privacy) async {
    try {
      final status = await _socialService.getFollowStatus(targetId);
      final bool wasNotFollowing = !status['isFollowing']! && !status['isPending']!;

      await _socialService.toggleFollow(targetId, privacy);

      if (wasNotFollowing) {
        final myId = _socialService.currentUserId;
        if (myId != null) {
          await _missionService.updateProgress(myId, 'social', 1.0, targetId);
        }
      }

      final myId = _socialService.currentUserId;
      if (myId != null) {
        await refreshSocialStats(myId);
      }

    } catch (e) {
      debugPrint("Error a toggleFollow: $e");
      rethrow;
    }
  }

  Future<SocialStats> getOtherUserStats(String userId) {
    return _socialService.getSocialOverview(userId);
  }

  Future<UserModel?> getUserById(String userId) async {
    return await _socialService.getUserById(userId);
  }

  Future<void> acceptFollowRequest(String reqId, String followerId) async {
    await _socialService.acceptFollowRequest(reqId, followerId);
    final myId = _socialService.currentUserId;
    if (myId != null) await refreshSocialStats(myId);
  }

  Future<void> unfollowOrCancel(String targetId, bool isPending) async {
    await _socialService.unfollowOrCancel(targetId, isPending);
    final myId = _socialService.currentUserId;
    if (myId != null) await refreshSocialStats(myId);
  }

  Future<void> removeFollower(String followerId) async {
    await _socialService.removeFollower(followerId);
    final myId = _socialService.currentUserId;
    if (myId != null) await refreshSocialStats(myId);
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() => _socialService.getPendingRequests();

  Future<List<Map<String, dynamic>>> getFollowNotifications() => _socialService.getFollowNotifications();

  Future<void> markNotificationsAsRead() => _socialService.markNotificationsAsRead();

  Future<void> rejectFollowRequest(String reqId) => _socialService.rejectFollowRequest(reqId);

  Future<Map<String, bool>> getFollowStatus(String targetId) => _socialService.getFollowStatus(targetId);

  Future<void> followUser(String targetId, String privacy) => _socialService.followUser(targetId, privacy);

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) => _socialService.getFollowersList(userId);

  Future<List<Map<String, dynamic>>> getFollowingList(String userId) => _socialService.getFollowingList(userId);

  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) => _socialService.searchUsers(query, limit: limit);

}