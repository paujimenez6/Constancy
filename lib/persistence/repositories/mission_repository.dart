import 'package:supabase_flutter/supabase_flutter.dart';

class MissionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> assignarMissionsDiaries(String userId) async {
    await _supabase.rpc('assignar_missions_diaries', params: {'p_user_id': userId});
  }

  Future<List<Map<String, dynamic>>> getUserMissions(String userId) async {
    final response = await _supabase
        .from('user_missions')
        .select('*, missions_definicions (*)')
        .eq('user_id', userId)
        .eq('data_assignada', DateTime.now().toIso8601String().split('T')[0]);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> incrementMissionProgress(String userId, String type, double amount, String itemId) async {
    await _supabase.rpc('incrementar_progres_missio', params: {
      'p_user_id': userId,
      'p_tipus_missio': type,
      'p_quantitat': amount,
      'p_item_id': itemId,
    });
  }

  Future<void> claimMissionReward(String userMissionId, String userId) async {
    await _supabase.rpc('reclamar_recompensa_missio', params: {
      'p_user_mission_id': userMissionId,
      'p_user_id': userId,
    });
  }

  Stream<List<Map<String, dynamic>>> listenToUserMissions(String userId) {
    return _supabase
        .from('user_missions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((event) async {
      final data = await getUserMissions(userId);
      return data;
    });
  }
}