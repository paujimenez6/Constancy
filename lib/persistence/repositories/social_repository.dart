import 'package:supabase_flutter/supabase_flutter.dart';

class SocialRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, bool>> getFollowStatus(String targetUserId) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    final followRes = await _supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    final requestRes = await _supabase
        .from('follow_requests')
        .select()
        .eq('sender_id', currentUserId)
        .eq('receiver_id', targetUserId)
        .maybeSingle();

    return {
      'isFollowing': followRes != null,
      'isPending': requestRes != null,
    };
  }

  Future<void> followUser(String targetUserId, String privacy) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    if (privacy == 'public') {
      await _supabase.from('follows').insert({
        'follower_id': currentUserId,
        'following_id': targetUserId,
      });
    } else {
      await _supabase.from('follow_requests').insert({
        'sender_id': currentUserId,
        'receiver_id': targetUserId,
      });
    }
  }

  Future<void> unfollowOrCancel(String targetUserId, bool isPending) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    if (isPending) {
      await _supabase
          .from('follow_requests')
          .delete()
          .eq('sender_id', currentUserId)
          .eq('receiver_id', targetUserId);
    } else {
      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final currentUserId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('follow_requests')
        .select('*, profiles:sender_id(nickname, nom, cognom, imatge_perfil)')
        .eq('receiver_id', currentUserId);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> acceptFollowRequest(String requestId, String followerId) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    await _supabase.from('follows').insert({
      'follower_id': followerId,
      'following_id': currentUserId,
    });

    await _supabase.from('follow_requests').delete().eq('id', requestId);
  }

  Future<void> rejectFollowRequest(String requestId) async {
    await _supabase.from('follow_requests').delete().eq('id', requestId);
  }

  Future<int> getFollowersCount(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('*')
        .eq('following_id', userId);
    return (res as List).length;
  }

  Future<int> getFollowingCount(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('*')
        .eq('follower_id', userId);
    return (res as List).length;
  }

  Future<bool> checkPendingRequests() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    final res = await _supabase
        .from('follow_requests')
        .select('*')
        .eq('receiver_id', currentUserId);
    return (res as List).isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('profiles:follower_id(id, nickname, nom, cognom, imatge_perfil, configuracio_privacitat, nivell_xp)')
        .eq('following_id', userId);
    return (res as List).map((e) => e['profiles'] as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getFollowingList(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('profiles:following_id(id, nickname, nom, cognom, imatge_perfil, configuracio_privacitat, nivell_xp)')
        .eq('follower_id', userId);
    return (res as List).map((e) => e['profiles'] as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getFollowNotifications() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    final res = await _supabase
        .from('notifications')
        .select('*, profiles:sender_id(id, nickname, nom, cognom, imatge_perfil, configuracio_privacitat, nivell_xp)')
        .eq('receiver_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> markNotificationsAsRead() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('receiver_id', currentUserId);
  }

  Future<void> removeFollower(String followerId) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', currentUserId);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      final data = await _supabase
          .from('profiles')
          .select()
          .ilike('nickname', '%$query%')
          .neq('id', currentUserId)
          .limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error a SocialRepository.searchUsers: $e");
      return [];
    }
  }
}