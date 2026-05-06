import 'package:supabase_flutter/supabase_flutter.dart';

class SocialRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Comprova si seguim a un usuari o si tenim una petició pendent
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

  // Envia una petició de seguiment o segueix directament segons privacitat
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

  // Deixa de seguir o cancel·la una petició enviada
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

  // Obté les peticions de seguiment que hem rebut
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final currentUserId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('follow_requests')
        .select('*, profiles:sender_id(id, nickname, nom, cognom, imatge_perfil, punts_xp, configuracio_privacitat)')
        .eq('receiver_id', currentUserId);

    return List<Map<String, dynamic>>.from(res);
  }

  // Accepta una petició de seguiment
  Future<void> acceptFollowRequest(String requestId, String followerId) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    await _supabase.from('follows').insert({
      'follower_id': followerId,
      'following_id': currentUserId,
    });

    await _supabase.from('follow_requests').delete().eq('id', requestId);
  }

  // Rebutja una petició de seguiment
  Future<void> rejectFollowRequest(String requestId) async {
    await _supabase.from('follow_requests').delete().eq('id', requestId);
  }

  // Comptadors de seguidors i seguits
  Future<int> getFollowersCount(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('follower_id')
        .eq('following_id', userId);
    return (res as List).length;
  }

  Future<int> getFollowingCount(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);
    return (res as List).length;
  }

  // Comprova si hi ha peticions pendents (per al punt vermell de notificacions)
  Future<bool> checkPendingRequests() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    final res = await _supabase
        .from('follow_requests')
        .select('id')
        .eq('receiver_id', currentUserId);
    return (res as List).isNotEmpty;
  }

  // Llistes d'usuaris (Seguidors)
  Future<List<Map<String, dynamic>>> getFollowersList(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('profiles:follower_id(id, nickname, nom, cognom, imatge_perfil, punts_xp, configuracio_privacitat)')
        .eq('following_id', userId);
    return (res as List).map((e) => e['profiles'] as Map<String, dynamic>).toList();
  }

  // Llistes d'usuaris (Seguint)
  Future<List<Map<String, dynamic>>> getFollowingList(String userId) async {
    final res = await _supabase
        .from('follows')
        .select('profiles:following_id(id, nickname, nom, cognom, imatge_perfil, punts_xp, configuracio_privacitat)')
        .eq('follower_id', userId);
    return (res as List).map((e) => e['profiles'] as Map<String, dynamic>).toList();
  }

  // Obté les notificacions d'activitat recent
  Future<List<Map<String, dynamic>>> getFollowNotifications() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    final res = await _supabase
        .from('notifications')
        .select('*, profiles:sender_id(id, nickname, nom, cognom, imatge_perfil, configuracio_privacitat, punts_xp)')
        .eq('receiver_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // Marca notificacions com a llegides
  Future<void> markNotificationsAsRead() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('receiver_id', currentUserId);
  }

  // Elimina un seguidor de la nostra llista
  Future<void> removeFollower(String followerId) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', currentUserId);
  }

  // Cerca d'usuaris per nickname
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // Seleccionem explícitament punts_xp i eliminem nivell_xp de la consulta
      final data = await _supabase
          .from('profiles')
          .select('id, nickname, nom, cognom, imatge_perfil, punts_xp, configuracio_privacitat')
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