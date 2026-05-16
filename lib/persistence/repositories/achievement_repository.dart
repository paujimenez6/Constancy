import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/achievement_model.dart';

class AchievementRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    final response = await _supabase
        .from('achievements')
        .select('*, user_achievements!left(*)');

    return (response as List).map((json) {
      final userProgressList = json['user_achievements'] as List? ?? [];

      final userProgress = userProgressList.firstWhere(
            (element) => element['user_id'] == userId,
        orElse: () => {},
      );

      return AchievementModel.fromJson({...json, ...userProgress});
    }).toList();
  }

  Future<void> updateProgress(String userId, String condicio, int increment) async {
    await _supabase.rpc('update_achievement_progress', params: {
      'p_user_id': userId,
      'p_condicio_codi': condicio,
      'p_increment': increment,
    });
  }

  Future<bool> markAsClaimed(String achId, String userId, int xp) async {
    try {
      await _supabase
          .from('user_achievements')
          .update({'reclamat': true})
          .eq('achievement_id', achId)
          .eq('user_id', userId);

      await _supabase.rpc('increment_user_xp', params: {
        'p_user_id': userId,
        'p_xp': xp,
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}