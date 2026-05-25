import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/achievement_model.dart';

class AchievementRepository {
  final SupabaseClient _supabase;
  AchievementRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

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

      final String realAchievementId = json['id'];
      final Map<String, dynamic> combined = {...json, ...userProgress};
      combined['id'] = realAchievementId;

      return AchievementModel.fromJson(combined);
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
      final response = await _supabase.rpc('claim_achievement_reward', params: {
        'p_achievement_id': achId,
        'p_user_id': userId,
        'p_xp': xp,
      });

      return response as bool? ?? false;
    } catch (e) {
      debugPrint("Error al reclamar recompensa al repositori: $e");
      return false;
    }
  }

  RealtimeChannel subscribeToAchievementChanges(String userId, Function onUpdate) {
    return _supabase
        .channel('user_achievements_$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'user_achievements',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) => onUpdate(),
    )
        .subscribe();
  }

  Future<void> setAbsoluteProgress(String userId, String condicio, int value) async {
    await _supabase.rpc('set_achievement_progress_absolute', params: {
      'p_user_id': userId,
      'p_condicio_codi': condicio,
      'p_value': value,
    });
  }

  Future<void> syncPerfectDay(String userId, DateTime date, bool isPerfect) async {
    await _supabase.rpc('sincronitzar_dia_perfecte', params: {
      'p_user_id': userId,
      'p_date': date.toIso8601String().split('T').first,
      'p_is_perfect': isPerfect,
    });
  }
}