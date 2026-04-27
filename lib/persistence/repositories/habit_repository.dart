import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';

class HabitRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<HabitModel>> getHabits() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return data.map((json) => HabitModel.fromJson(json)).toList();
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
    }, onConflict: 'habit_id, data_registre');
  }

  Future<void> updateHabitRecordComment(String habitId, String userId, DateTime date, String comentari) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      await _supabase.from('habit_records').upsert({
        'habit_id': habitId,
        'user_id': userId,
        'data_registre': dateStr,
        'comentari': comentari,
      }, onConflict: 'habit_id, data_registre');
    } catch (e) {
      throw Exception('Error al Repositori en actualitzar el comentari: $e');
    }
  }
}