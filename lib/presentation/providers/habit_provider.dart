import 'package:flutter/material.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;

  List<HabitModel> _habits = [];
  List<HabitRecordModel> _monthlyRecords = [];
  List<HabitRecordModel> _allTimeRecords = [];
  Map<String, HabitRecordModel> _dailyRecords = {};

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;

  HabitProvider(this._habitService);

  List<HabitModel> get habits => _habits;
  Map<String, HabitRecordModel> get dailyRecords => _dailyRecords;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  DateTime get focusedMonth => _focusedMonth;
  List<HabitRecordModel> get monthlyRecords => _monthlyRecords;
  List<HabitRecordModel> get allTimeRecords => _allTimeRecords;

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

      _dailyRecords = {for (var r in recordsList) r.habitId: r};
    } catch (e) {
      debugPrint("Error carregant dades d'hàbits: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<HabitRecordModel>> getRecordsForRange(DateTime start, DateTime end) async {
    try {
      return await _habitService.getRecordsForRange(start, end);
    } catch (e) {
      debugPrint("Error obtenint registres per rang: $e");
      return [];
    }
  }

  Future<void> loadMonthlyData(DateTime month) async {
    _focusedMonth = month;
    _isLoading = true;
    notifyListeners();

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    try {
      _monthlyRecords = await _habitService.getRecordsForRange(startOfMonth, endOfMonth);
    } catch (e) {
      debugPrint("Error carregant dades mensuals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllTimeData() async {
    try {
      _allTimeRecords = await _habitService.getAllRecords();
      notifyListeners();
    } catch (e) {
      debugPrint("Error carregant dades globals: $e");
    }
  }

  void _syncRecordInAllLists(HabitRecordModel updatedRecord) {
    final recordDate = DateTime(updatedRecord.dataRegistre.year, updatedRecord.dataRegistre.month, updatedRecord.dataRegistre.day);
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (recordDate.isAtSameMomentAs(selectedDateOnly)) {
      _dailyRecords[updatedRecord.habitId] = updatedRecord;
    }

    int monthIndex = _monthlyRecords.indexWhere((r) =>
    r.habitId == updatedRecord.habitId &&
        r.dataRegistre.year == updatedRecord.dataRegistre.year &&
        r.dataRegistre.month == updatedRecord.dataRegistre.month &&
        r.dataRegistre.day == updatedRecord.dataRegistre.day);

    if (monthIndex != -1) {
      _monthlyRecords[monthIndex] = updatedRecord;
    } else if (updatedRecord.dataRegistre.month == _focusedMonth.month && updatedRecord.dataRegistre.year == _focusedMonth.year) {
      _monthlyRecords.add(updatedRecord);
    }

    int allTimeIndex = _allTimeRecords.indexWhere((r) =>
    r.habitId == updatedRecord.habitId &&
        r.dataRegistre.year == updatedRecord.dataRegistre.year &&
        r.dataRegistre.month == updatedRecord.dataRegistre.month &&
        r.dataRegistre.day == updatedRecord.dataRegistre.day);

    if (allTimeIndex != -1) {
      _allTimeRecords[allTimeIndex] = updatedRecord;
    } else {
      _allTimeRecords.add(updatedRecord);
    }

    notifyListeners();
  }

  List<HabitModel> getExpectedHabitsForDate(DateTime date) {
    return _habits.where((h) {
      final inici = DateTime(h.dataInici.year, h.dataInici.month, h.dataInici.day);
      bool dinsRang = (date.isAtSameMomentAs(inici) || date.isAfter(inici)) &&
          (h.dataFi == null || date.isBefore(DateTime(h.dataFi!.year, h.dataFi!.month, h.dataFi!.day + 1)));

      if (!dinsRang) return false;

      if (h.periodeObjectiu == PeriodeObjectiu.diari) return true;
      if (h.periodeObjectiu == PeriodeObjectiu.setmanal) return date.weekday == h.dataInici.weekday;
      if (h.periodeObjectiu == PeriodeObjectiu.mensual) {
        int diaObj = h.dataInici.day;
        int ultimDia = DateTime(date.year, date.month + 1, 0).day;
        return date.day == (diaObj > ultimDia ? ultimDia : diaObj);
      }
      return false;
    }).toList();
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
      await loadMonthlyData(_focusedMonth);
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
      _monthlyRecords.removeWhere((r) => r.habitId == habitId);
      _allTimeRecords.removeWhere((r) => r.habitId == habitId);
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

      final updatedRecord = HabitRecordModel(
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

      _syncRecordInAllLists(updatedRecord);
      await _recalculateStreaks(habitId);
    } catch (e) {
      debugPrint("Error guardant progrés: $e");
      rethrow;
    }
  }

  Future<void> _recalculateStreaks(String habitId) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final records = await _habitService.getAllRecordsForHabit(habitId);

      final completed = records
          .where((r) => r.completat)
          .map((r) => DateTime(r.dataRegistre.year, r.dataRegistre.month, r.dataRegistre.day))
          .toList();

      completed.sort((a, b) => b.compareTo(a));

      if (completed.isEmpty) {
        await _updateHabitStreaks(habitId, 0, 0);
        return;
      }

      int maxStreak = 1;
      int currentMax = 1;
      for (int i = 0; i < completed.length - 1; i++) {
        if (_areConsecutive(completed[i], completed[i + 1], habit.periodeObjectiu)) {
          currentMax++;
        } else {
          currentMax = 1;
        }
        if (currentMax > maxStreak) maxStreak = currentMax;
      }

      int actualStreak = 0;
      if (_isStreakAlive(completed.first, habit.periodeObjectiu)) {
        actualStreak = 1;
        for (int i = 0; i < completed.length - 1; i++) {
          if (_areConsecutive(completed[i], completed[i + 1], habit.periodeObjectiu)) {
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

  bool _areConsecutive(DateTime newer, DateTime older, PeriodeObjectiu periode) {
    if (periode == PeriodeObjectiu.diari) {
      return newer.difference(older).inDays == 1;
    } else if (periode == PeriodeObjectiu.setmanal) {
      return newer.difference(older).inDays == 7;
    } else {
      int monthsDiff = (newer.year - older.year) * 12 + (newer.month - older.month);
      return monthsDiff == 1;
    }
  }

  bool _isStreakAlive(DateTime lastCompleted, PeriodeObjectiu periode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (periode == PeriodeObjectiu.diari) {
      return lastCompleted.isAtSameMomentAs(today) ||
          lastCompleted.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
    } else if (periode == PeriodeObjectiu.setmanal) {
      return lastCompleted.isAtSameMomentAs(today) ||
          today.difference(lastCompleted).inDays <= 7;
    } else {
      int monthsDiff = (today.year - lastCompleted.year) * 12 + (today.month - lastCompleted.month);
      return monthsDiff <= 1;
    }
  }

  Future<void> _updateHabitStreaks(String habitId, int actual, int millor) async {
    await _habitService.updateHabitStreaks(habitId, actual, millor);
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(ratxaActual: actual, millorRatxa: millor);
      notifyListeners();
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

      final updatedRecord = HabitRecordModel(
        id: currentRecord?.id ?? '',
        habitId: habitId,
        userId: currentRecord?.userId ?? '',
        dataRegistre: _selectedDate,
        completat: currentCompleted,
        valorProgres: currentProgress,
        comentari: comentari,
        createdAt: currentRecord?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _syncRecordInAllLists(updatedRecord);
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

      if (!esValidInici || !esValidFi || h.arxivat) return false;

      if (h.periodeObjectiu == PeriodeObjectiu.diari) {
        return true;
      } else if (h.periodeObjectiu == PeriodeObjectiu.setmanal) {
        return sel.weekday == inici.weekday;
      } else if (h.periodeObjectiu == PeriodeObjectiu.mensual) {
        int diaObjectiu = inici.day;
        int ultimDiaMesActual = DateTime(sel.year, sel.month + 1, 0).day;
        if (diaObjectiu > ultimDiaMesActual) {
          return sel.day == ultimDiaMesActual;
        }
        return sel.day == diaObjectiu;
      }
      return false;
    }).toList();
  }
}