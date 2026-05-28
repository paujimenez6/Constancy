import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/habit_group_member_model.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';

class HabitRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<HabitModel>> getHabits() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('v_user_habits')
        .select()
        .or('user_id.eq.$userId, participant_id.eq.$userId')
        .order('created_at');

    final List<HabitModel> allHabits = data.map((json) => HabitModel.fromJson(json)).toList();

    final Map<String, HabitModel> uniqueHabits = {};
    for (var habit in allHabits) {
      uniqueHabits[habit.id] = habit;
    }

    return uniqueHabits.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<HabitModel>> getHabitsByUserId(String userId) async {
    try {
      final data = await _supabase
          .from('v_user_habits')
          .select()
          .or('user_id.eq.$userId, participant_id.eq.$userId')
          .eq('arxivat', false)
          .order('created_at');

      final List<HabitModel> allHabits = data.map((json) => HabitModel.fromJson(json)).toList();

      final Map<String, HabitModel> uniqueHabits = {};
      for (var habit in allHabits) {
        uniqueHabits[habit.id] = habit;
      }

      return uniqueHabits.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      debugPrint("Error al repository (getHabitsByUserId): $e");
      return [];
    }
  }

  Future<HabitModel> createHabit(HabitModel habit) async {
    final userId = _supabase.auth.currentUser!.id;
    final habitData = habit.toJson();
    habitData['user_id'] = userId;

    final data = await _supabase
        .from('habits')
        .insert(habitData)
        .select()
        .single();

    return HabitModel.fromJson(data);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _supabase
        .from('habits')
        .update(habit.toJson())
        .eq('id', habit.id);
  }

  Future<void> deleteHabit(String habitId) async {
    await _supabase.from('habits').delete().eq('id', habitId);
  }

  Future<void> updateHabitStreaks(String habitId, int ratxaActual, int millorRatxa) async {
    await _supabase.from('habits').update({
      'ratxa_actual': ratxaActual,
      'millor_ratxa': millorRatxa,
    }).eq('id', habitId);
  }

  Future<List<HabitRecordModel>> getRecordsForDate(DateTime date) async {
    final userId = _supabase.auth.currentUser!.id;
    final dateStr = date.toIso8601String().split('T').first;

    final data = await _supabase
        .from('habit_records')
        .select()
        .eq('user_id', userId)
        .eq('data_registre', dateStr);

    return data.map((json) => HabitRecordModel.fromJson(json)).toList();
  }

  Future<List<HabitRecordModel>> getRecordsForRange(DateTime start, DateTime end) async {
    final userId = _supabase.auth.currentUser!.id;
    final startStr = start.toIso8601String().split('T').first;
    final endStr = end.toIso8601String().split('T').first;

    final data = await _supabase
        .from('habit_records')
        .select()
        .eq('user_id', userId)
        .gte('data_registre', startStr)
        .lte('data_registre', endStr);

    return data.map((json) => HabitRecordModel.fromJson(json)).toList();
  }

  Future<List<HabitRecordModel>> getAllRecordsForHabit(String habitId) async {
    final data = await _supabase
        .from('habit_records')
        .select()
        .eq('habit_id', habitId)
        .order('data_registre', ascending: false);

    return data.map((json) => HabitRecordModel.fromJson(json)).toList();
  }

  Future<List<HabitRecordModel>> getAllRecords() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('habit_records')
        .select()
        .eq('user_id', userId)
        .order('data_registre', ascending: false);

    return data.map((json) => HabitRecordModel.fromJson(json)).toList();
  }

  Future<void> saveRecord({
    required String habitId,
    required DateTime date,
    required double valorProgres,
    required bool completat,
    String? comentari,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    final dateStr = date.toIso8601String().split('T').first;

    await _supabase.from('habit_records').upsert({
      'habit_id': habitId,
      'user_id': userId,
      'data_registre': dateStr,
      'valor_progres': valorProgres,
      'completat': completat,
      'comentari': comentari,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'habit_id, user_id, data_registre');
  }

  Future<void> updateHabitRecordComment(String habitId, String userId, DateTime date, String comentari) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      await _supabase.from('habit_records').upsert({
        'habit_id': habitId,
        'user_id': userId,
        'data_registre': dateStr,
        'comentari': comentari,
      }, onConflict: 'habit_id, user_id, data_registre');
    } catch (e) {
      throw Exception('Error al Repositori en actualitzar el comentari: $e');
    }
  }

  Future<void> applyStreakShield(String userId, DateTime date, String inventoryId) async {
    await _supabase.rpc('aplicar_protector_ratxa', params: {
      'p_user_id': userId,
      'p_date': date.toIso8601String().split('T')[0],
      'p_inventory_id': inventoryId,
    });
  }

  Future<void> unshieldDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    await _supabase
        .from('habit_records')
        .update({'is_shielded': false, 'completat': false})
        .eq('user_id', userId)
        .eq('data_registre', dateStr);
  }

  Future<HabitModel> createGroupHabit(HabitModel habit, String inviteCode) async {
    final userId = _supabase.auth.currentUser!.id;

    final habitData = habit.toJson();
    habitData['user_id'] = userId;
    habitData['is_group'] = true;

    final hBase = await _supabase.from('habits').insert(habitData).select().single();
    final hId = hBase['id'];

    try {
      await _supabase.from('group_habits').insert({
        'id': hId,
        'codi_invitacio': inviteCode,
        'creat_per': userId,
      });

      await _supabase.from('participacions_habits').insert({
        'user_id': userId,
        'habit_grupal_id': hId,
        'es_administrador': true,
      });

      return HabitModel.fromJson(hBase);
    } catch (e) {
      await _supabase.from('habits').delete().eq('id', hId);
      rethrow;
    }
  }

  Future<void> joinByCode(String userId, String code) async {
    try {
      await _supabase.rpc('unir_a_habit_grupal', params: {
        'p_user_id': userId,
        'p_codi': code,
      });
    } on PostgrestException catch (e) {
      if (e.code == 'P0001' || e.code == '23505') {
        throw 'invalid_code';
      }
      rethrow;
    }
  }

  Future<String?> getGroupInviteCode(String habitId) async {
    final data = await _supabase
        .from('group_habits')
        .select('codi_invitacio')
        .eq('id', habitId)
        .maybeSingle();
    return data?['codi_invitacio'];
  }

  Future<List<HabitGroupMember>> getGroupMembers(String habitId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;

      final List<dynamic> data = await _supabase.rpc(
        'get_group_ranking_custom_date',
        params: {
          'p_habit_id': habitId,
          'p_date': dateStr,
        },
      );

      return data.map((m) => HabitGroupMember.fromJson(m)).toList();
    } catch (e) {
      debugPrint("ERROR REPOSITORY (getGroupMembers): $e");
      return [];
    }
  }

  Future<double> getGroupTotalProgress(String habitId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final data = await _supabase.rpc('get_group_total_progress', params: {
      'p_habit_id': habitId,
      'p_date': dateStr,
    });
    return (data as num).toDouble();
  }

  RealtimeChannel subscribeToGroupChanges(String habitId, Function onUpdate) {
    return _supabase
        .channel('group_ranking_$habitId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'participacions_habits',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'habit_grupal_id',
        value: habitId,
      ),
      callback: (payload) => onUpdate(),
    )
        .subscribe();
  }

  Future<void> leaveGroupHabit(String habitId, String userId) async {
    await _supabase
        .from('habit_records')
        .delete()
        .eq('habit_id', habitId)
        .eq('user_id', userId);

    await _supabase
        .from('participacions_habits')
        .delete()
        .eq('habit_grupal_id', habitId)
        .eq('user_id', userId);
  }

  Future<List<HabitRecordModel>> getGroupRecordsForRange(String habitId, DateTime start, DateTime end) async {
    final startStr = start.toIso8601String().split('T').first;
    final endStr = end.toIso8601String().split('T').first;

    final data = await _supabase
        .from('habit_records')
        .select()
        .eq('habit_id', habitId)
        .gte('data_registre', startStr)
        .lte('data_registre', endStr);

    return data.map((json) => HabitRecordModel.fromJson(json)).toList();
  }
}