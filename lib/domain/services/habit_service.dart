import '../../persistence/repositories/habit_repository.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';

class HabitService {
  final HabitRepository _habitRepository;

  HabitService(this._habitRepository);

  Future<List<HabitModel>> getHabits() => _habitRepository.getHabits();

  Future<HabitModel> createHabit(HabitModel habit) => _habitRepository.createHabit(habit);

  Future<void> updateHabit(HabitModel habit) => _habitRepository.updateHabit(habit);

  Future<void> deleteHabit(String habitId) => _habitRepository.deleteHabit(habitId);

  Future<void> updateHabitStreaks(String habitId, int ratxaActual, int millorRatxa) =>
      _habitRepository.updateHabitStreaks(habitId, ratxaActual, millorRatxa);

  Future<List<HabitRecordModel>> getRecordsForDate(DateTime date) =>
      _habitRepository.getRecordsForDate(date);

  Future<List<HabitRecordModel>> getAllRecordsForHabit(String habitId) =>
      _habitRepository.getAllRecordsForHabit(habitId);

  Future<void> saveRecord({
    required String habitId,
    required DateTime date,
    required double valorProgres,
    required bool completat,
    String? comentari,
  }) => _habitRepository.saveRecord(
    habitId: habitId,
    date: date,
    valorProgres: valorProgres,
    completat: completat,
    comentari: comentari,
  );
}