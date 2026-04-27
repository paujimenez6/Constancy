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
      }

      await _recalculateStreaks(habit.id);
      await loadDataForDate(_selectedDate);
      notifyListeners();

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
  }) async {
    try {
      final existingComment = _dailyRecords[habitId]?.comentari;

      await _habitService.saveRecord(
        habitId: habitId,
        date: _selectedDate,
        valorProgres: valorProgres,
        completat: completat,
        comentari: existingComment,
      );

      _dailyRecords[habitId] = HabitRecordModel(
        id: _dailyRecords[habitId]?.id ?? '',
        habitId: habitId,
        userId: _dailyRecords[habitId]?.userId ?? '',
        dataRegistre: _selectedDate,
        completat: completat,
        valorProgres: valorProgres,
        comentari: existingComment,
        createdAt: _dailyRecords[habitId]?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _recalculateStreaks(habitId);

      notifyListeners();
    } catch (e) {
      debugPrint("Error guardant progrés: $e");
      rethrow;
    }
  }

  Future<void> _recalculateStreaks(String habitId) async {
    try {
      final records = await _habitService.getAllRecordsForHabit(habitId);
      if (records.isEmpty) return;

      final completedDates = records
          .where((r) => r.completat)
          .map((r) => DateTime(r.dataRegistre.year, r.dataRegistre.month, r.dataRegistre.day))
          .toList();

      completedDates.sort((a, b) => b.compareTo(a));

      if (completedDates.isEmpty) {
        await _updateHabitStreaks(habitId, 0, 0);
        return;
      }

      int maxStreak = 0;
      int currentCount = 0;
      if (completedDates.isNotEmpty) {
        currentCount = 1;
        maxStreak = 1;
        for (int i = 0; i < completedDates.length - 1; i++) {
          if (completedDates[i].difference(completedDates[i + 1]).inDays == 1) {
            currentCount++;
          } else if (completedDates[i].difference(completedDates[i + 1]).inDays > 0) {
            currentCount = 1;
          }
          if (currentCount > maxStreak) maxStreak = currentCount;
        }
      }

      int actualStreak = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      if (completedDates.first.isAtSameMomentAs(todayDate) ||
          completedDates.first.isAtSameMomentAs(yesterdayDate)) {
        actualStreak = 1;
        for (int i = 0; i < completedDates.length - 1; i++) {
          if (completedDates[i].difference(completedDates[i + 1]).inDays == 1) {
            actualStreak++;
          } else {
            break;
          }
        }
      }

      await _updateHabitStreaks(habitId, actualStreak, maxStreak);
    } catch (e) {
      debugPrint("Error calculant ratxes: $e");
    }
  }

  Future<void> _updateHabitStreaks(String habitId, int actual, int millor) async {
    await _habitService.updateHabitStreaks(habitId, actual, millor);

    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        ratxaActual: actual,
        millorRatxa: millor,
      );
    }
  }

  Future<void> archiveHabit(String habitId, bool arxivat) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex != -1) {
        final updatedHabit = _habits[habitIndex].copyWith(arxivat: arxivat);
        await _habitService.updateHabit(updatedHabit);
        _habits[habitIndex] = updatedHabit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error arxivant hàbit: $e");
      rethrow;
    }
  }

  Future<void> updateComment({
    required String habitId,
    required String? comentari,
  }) async {
    try {
      final currentRecord = _dailyRecords[habitId];
      final currentProgress = currentRecord?.valorProgres ?? 0.0;
      final currentCompleted = currentRecord?.completat ?? false;

      await _habitService.saveRecord(
        habitId: habitId,
        date: _selectedDate,
        valorProgres: currentProgress,
        completat: currentCompleted,
        comentari: comentari,
      );

      if (_dailyRecords.containsKey(habitId)) {
        _dailyRecords[habitId] = _dailyRecords[habitId]!.copyWith(
            comentari: comentari,
            updateComentari: true
        );
      } else {
        _dailyRecords[habitId] = HabitRecordModel(
          id: '', habitId: habitId, userId: '',
          dataRegistre: _selectedDate,
          completat: currentCompleted,
          valorProgres: currentProgress,
          comentari: comentari,
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error actualitzant comentari: $e");
      rethrow;
    }
  }

  List<HabitModel> get filteredHabits {
    return _habits.where((h) {
      final sel = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final inici = DateTime(h.dataInici.year, h.dataInici.month, h.dataInici.day);

      bool esValidInici = sel.isAtSameMomentAs(inici) || sel.isAfter(inici);

      bool esValidFi = h.dataFi == null ||
          sel.isAtSameMomentAs(DateTime(h.dataFi!.year, h.dataFi!.month, h.dataFi!.day)) ||
          sel.isBefore(DateTime(h.dataFi!.year, h.dataFi!.month, h.dataFi!.day));

      return esValidInici && esValidFi && !h.arxivat;
    }).toList();
  }
}