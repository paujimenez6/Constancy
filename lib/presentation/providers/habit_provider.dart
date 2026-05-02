import 'package:flutter/material.dart';
import '../../domain/models/chart_data_model.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/models/stats_model.dart';
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

  List<HabitModel> get filteredHabits => _habitService.filterHabitsForDate(_habits, _selectedDate);

  List<HabitModel> get archivedHabits => _habitService.getArchivedHabits(_habits);

  List<String> getMonthLabels() => _habitService.getLocalizedMonths();

  List<String> get availableCategories => _habitService.getUniqueCategories(_habits);

  List<ChartDataPoint> getStatisticsChartData({
    required bool isMensual,
    required HabitModel? selectedHabit,
    required String? selectedCategory, // Afegim categoria
    required DateTime viewDate,
    bool isCumulative = false,
  }) {
    // Filtrem els registres segons la selecció
    List<HabitRecordModel> filteredRecords;

    if (selectedCategory != null) {
      final idsInDynamicCategory = _habits
          .where((h) => h.grup == selectedCategory)
          .map((h) => h.id)
          .toSet();

      filteredRecords = (isMensual ? _monthlyRecords : _allTimeRecords)
          .where((r) => idsInDynamicCategory.contains(r.habitId))
          .toList();
    } else {
      filteredRecords = isMensual ? _monthlyRecords : _allTimeRecords;
    }

    return _habitService.getChartData(
      records: filteredRecords,
      isMensual: isMensual,
      referenceDate: viewDate,
      selectedHabit: selectedHabit, // Si és null i hi ha categoria, la lògica serà la de "General"
      isCumulative: isCumulative,
    );
  }
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
      _dailyRecords = {for (var r in (results[1] as List<HabitRecordModel>)) r.habitId: r};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress({required String habitId, required double valorProgres, required bool completat}) async {
    try {
      final existingComment = _dailyRecords[habitId]?.comentari;
      await _habitService.processProgressUpdate(
        habitId: habitId,
        date: _selectedDate,
        valorProgres: valorProgres,
        completat: completat,
        comentari: existingComment,
      );

      await loadDataForDate(_selectedDate);
      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } catch (e) {
      debugPrint("Error al Provider: $e");
      rethrow;
    }
  }

  Future<void> createHabit(HabitModel habit) async {
    await _habitService.createHabit(habit);
    await loadDataForDate(_selectedDate);
    await loadAllTimeData();
  }

  Future<void> updateHabit(HabitModel habit) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _habitService.updateHabit(habit);

      await loadDataForDate(_selectedDate);
      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitService.deleteHabit(habitId);
    await loadDataForDate(_selectedDate);
    await loadMonthlyData(_focusedMonth);
    await loadAllTimeData();
  }

  Future<void> archiveHabit(String habitId, bool arxivat) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    await _habitService.updateHabit(habit.copyWith(arxivat: arxivat));
    await loadDataForDate(_selectedDate);
    await loadAllTimeData();
  }

  Future<void> loadMonthlyData(DateTime month) async {
    _focusedMonth = month;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    _monthlyRecords = await _habitService.getRecordsForRange(start, end);
    notifyListeners();
  }

  Future<List<HabitRecordModel>> getRecordsForRange(DateTime start, DateTime end) {
    return _habitService.getRecordsForRange(start, end);
  }

  Future<void> loadAllTimeData() async {
    _allTimeRecords = await _habitService.getAllRecords();
    notifyListeners();
  }

  List<HabitModel> getExpectedHabitsForDate(DateTime date) =>
      _habitService.filterHabitsForDate(_habits, date, includeArchived: true);

  Future<void> changeDate(DateTime newDate) => loadDataForDate(newDate);

  Future<void> updateComment({required String habitId, required String? comentari}) async {
    final record = _dailyRecords[habitId];
    await _habitService.processProgressUpdate(
      habitId: habitId,
      date: _selectedDate,
      valorProgres: record?.valorProgres ?? 0.0,
      completat: record?.completat ?? false,
      comentari: comentari,
    );
    await loadDataForDate(_selectedDate);
    await loadAllTimeData();
  }

  HabitStats getStats({required bool isMensual, String? habitId, String? categoryId}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    List<HabitRecordModel> sourceRecords;

    // 1. Decidir el rang de dates i la font de registres
    if (isMensual) {
      start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      DateTime lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
      end = (_focusedMonth.year == now.year && _focusedMonth.month == now.month) ? now : lastDay;
      sourceRecords = _monthlyRecords;
    } else {
      if (_habits.isEmpty) return HabitStats();

      // Si filtrem per categoria o hàbit, la data d'inici "global" hauria de ser la de l'hàbit més antic d'aquell grup
      List<HabitModel> habitsToCheck = _habits;
      if (habitId != null) {
        habitsToCheck = _habits.where((h) => h.id == habitId).toList();
      } else if (categoryId != null) {
        habitsToCheck = _habits.where((h) => h.grup == categoryId).toList();
      }

      if (habitsToCheck.isEmpty) return HabitStats();

      start = habitsToCheck.map((h) => h.dataInici).reduce((a, b) => a.isBefore(b) ? a : b);
      end = now;
      sourceRecords = _allTimeRecords;
    }

    // 2. Filtrar la llista d'hàbits a analitzar segons la categoria si és necessari
    // Si hi ha una categoria seleccionada, només passem al servei els hàbits d'aquella categoria
    List<HabitModel> habitsForCalculation = _habits;
    if (categoryId != null) {
      habitsForCalculation = _habits.where((h) => h.grup == categoryId).toList();
    }

    // 3. Cridar al servei amb la llista (potencialment filtrada) d'hàbits
    return _habitService.calculateStats(
      allHabits: habitsForCalculation,
      records: sourceRecords,
      startDate: start,
      endDate: end,
      selectedHabitId: habitId,
    );
  }
}