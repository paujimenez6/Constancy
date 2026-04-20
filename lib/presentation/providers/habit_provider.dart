import 'package:flutter/material.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;

  List<HabitModel> _habits = [];

  Map<String, HabitRecordModel> _dailyRecords = {};

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  HabitProvider(this._habitService);

  List<HabitModel> get habits => _habits;
  Map<String, HabitRecordModel> get dailyRecords => _dailyRecords;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  Future<void> loadDataForDate(DateTime date) async {
    _isLoading = true;
    _selectedDate = date;
    notifyListeners();

    try {
      final results = await Future.wait([
        _habitService.getHabits(),
        _habitService.getRecordsForDate(date),
      ]);

      _habits = results[0] as List<HabitModel>;
      final recordsList = results[1] as List<HabitRecordModel>;

      _dailyRecords = { for (var r in recordsList) r.habitId : r };
    } catch (e) {
      debugPrint("Error carregant dades d'hàbits: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDate(DateTime newDate) async {
    await loadDataForDate(newDate);
  }

  Future<void> createHabit(HabitModel habit) async {
    try {
      final newHabit = await _habitService.createHabit(habit);
      _habits.add(newHabit);
      notifyListeners();
    } catch (e) {
      debugPrint("Error creant hàbit: $e");
      rethrow;
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error actualitzant hàbit: $e");
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      _dailyRecords.remove(habitId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error eliminant hàbit: $e");
      rethrow;
    }
  }

  Future<void> updateProgress({
    required String habitId,
    required double valorProgres,
    required bool completat,
    String? comentari,
  }) async {
    try {
      await _habitService.saveRecord(
        habitId: habitId,
        date: _selectedDate,
        valorProgres: valorProgres,
        completat: completat,
        comentari: comentari,
      );

      final updatedRecord = HabitRecordModel(
        id: _dailyRecords[habitId]?.id ?? '',
        habitId: habitId,
        userId: '',
        dataRegistre: _selectedDate,
        completat: completat,
        valorProgres: valorProgres,
        comentari: comentari,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _dailyRecords[habitId] = updatedRecord;
      notifyListeners();

    } catch (e) {
      debugPrint("Error guardant progrés: $e");
      rethrow;
    }
  }
}