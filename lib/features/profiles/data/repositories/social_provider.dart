import 'package:flutter/material.dart';
import 'social_repository.dart';

class SocialProvider extends ChangeNotifier {
  final SocialRepository _repo = SocialRepository();

  int _followersCount = 0;
  int _followingCount = 0;
  bool _hasPendingRequests = false;

  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  bool get hasPendingRequests => _hasPendingRequests;

  Future<void> refreshSocialStats(String userId) async {
    try {
      final results = await Future.wait([
        _repo.getFollowersCount(userId),
        _repo.getFollowingCount(userId),
        _repo.checkPendingRequests(),
      ]);

      _followersCount = results[0] as int;
      _followingCount = results[1] as int;
      _hasPendingRequests = results[2] as bool;

      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshSocialStats: $e");
    }
  }
}