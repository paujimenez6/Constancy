import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class LeagueRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getCurrentUserLeague(String userId) async {
    final now = DateTime.now().toIso8601String();
    return await _supabase
        .from('participacio_lliga')
        .select('*, lligues!inner(*)')
        .eq('user_id', userId)
        .lte('lligues.data_inici', now)
        .gte('lligues.data_fi', now)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getLeagueRanking(String leagueId) async {
    final response = await _supabase
        .from('participacio_lliga')
        .select('''*,profiles:user_id (nickname, nom, cognom, imatge_perfil, punts_xp, monedes, configuracio_privacitat)''')
        .eq('league_id', leagueId)
        .order('posicio_actual', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Stream<List<Map<String, dynamic>>> listenToRanking(String leagueId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    getLeagueRanking(leagueId).then((data) => controller.add(data));

    _supabase
        .channel('public:participacio_lliga:league_id=eq.$leagueId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'participacio_lliga',
      callback: (payload) async {
        final updatedData = await getLeagueRanking(leagueId);
        if (!controller.isClosed) controller.add(updatedData);
      },
    )
        .subscribe();

    return controller.stream;
  }

  Future<Map<String, dynamic>?> getPendingResult(String userId) async {
    return await _supabase
        .from('resultats_lliga')
        .select()
        .eq('user_id', userId)
        .eq('vists', false)
        .maybeSingle();
  }

  Future<void> markResultAsSeen(String resultId) async {
    await _supabase.from('resultats_lliga').update({'vists': true}).eq('id', resultId);
  }

  Stream<List<Map<String, dynamic>>> listenToNewResults(String userId) {
    return _supabase
        .from('resultats_lliga')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }

  Stream<List<Map<String, dynamic>>> listenToUserParticipation(String userId) {
    return _supabase
        .from('participacio_lliga')
        .stream(primaryKey: ['user_id', 'league_id'])
        .eq('user_id', userId);
  }
}