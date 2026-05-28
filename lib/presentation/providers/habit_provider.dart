import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/chart_data_model.dart';
import '../../domain/models/habit_group_member_model.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/models/stats_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/habit_service.dart';
import '../../domain/services/mission_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;
  final MissionService _missionService;
  final AchievementService _achievementService;

  List<HabitModel> _habits = [];
  List<HabitRecordModel> _monthlyRecords = [];
  List<HabitRecordModel> _allTimeRecords = [];
  Map<String, HabitRecordModel> _dailyRecords = {};
  List<HabitModel> _profileHabits = [];
  List<HabitGroupMember> _currentGroupMembers = [];
  String? _currentInviteCode;
  RealtimeChannel? _groupSubscription;
  double _currentGroupTotalProgress = 0.0;
  final Map<String, double> _groupTotals = {};
  final Map<String, RealtimeChannel> _activeSubscriptions = {};
  List<HabitRecordModel> _groupAggregatedMonthlyRecords = [];
  List<HabitRecordModel> _groupAggregatedAllTimeRecords = [];

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  bool _isLoading = false;

  HabitProvider(this._habitService, this._missionService, this._achievementService);

  List<HabitModel> get habits => _habits;
  List<HabitModel> get profileHabits => _profileHabits;
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
  List<HabitGroupMember> get currentGroupMembers => _currentGroupMembers;
  String? get currentInviteCode => _currentInviteCode;
  double get currentGroupTotalProgress => _currentGroupTotalProgress;
  Map<String, double> get groupTotals => _groupTotals;
  List<HabitRecordModel> get groupAggregatedMonthlyRecords => _groupAggregatedMonthlyRecords;

  List<ChartDataPoint> getStatisticsChartData({
    required bool isMensual,
    required HabitModel? selectedHabit,
    required String? selectedCategory,
    required DateTime viewDate,
    bool isCumulative = false,
    bool useGroupData = false,
  }) {
    List<HabitRecordModel> sourceRecords;

    if (useGroupData) {
      sourceRecords = isMensual ? _groupAggregatedMonthlyRecords : _groupAggregatedAllTimeRecords;
    } else {
      sourceRecords = isMensual ? _monthlyRecords : _allTimeRecords;
    }

    if (selectedCategory != null) {
      final idsInDynamicCategory = _habits
          .where((h) => h.grup == selectedCategory)
          .map((h) => h.id)
          .toSet();

      sourceRecords = sourceRecords.where((r) => idsInDynamicCategory.contains(r.habitId)).toList();
    }

    return _habitService.getChartData(
      records: sourceRecords,
      isMensual: isMensual,
      referenceDate: viewDate,
      selectedHabit: selectedHabit,
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
      final groupHabits = _habits.where((h) => h.isGroup).toList();
      _groupTotals.clear();
      for (var habit in groupHabits) {
        final total = await _habitService.getGroupTotalProgress(habit.id, date);
        _groupTotals[habit.id] = total;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void listenToAllVisibleGroups() {
    stopListeningToAllGroups();

    final visibleGroups = filteredHabits.where((h) => h.isGroup);
    for (var habit in visibleGroups) {
      _activeSubscriptions[habit.id] = _habitService.subscribeToGroupChanges(habit.id, () async {
        await loadDataForDate(_selectedDate);
        notifyListeners();
      });
    }
  }

  void stopListeningToAllGroups() {
    for (var sub in _activeSubscriptions.values) {
      sub.unsubscribe();
    }
    _activeSubscriptions.clear();
  }

  Future<void> loadProfileHabits(String targetUserId) async {
    _isLoading = true;
    _profileHabits = [];
    notifyListeners();

    try {
      final result = await _habitService.getHabitsByUserId(targetUserId);
      _profileHabits = result;
    } catch (e) {
      debugPrint("Error al Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress({required String habitId, required double valorProgres, required bool completat}) async {
    try {
      final myId = _habitService.currentUserId;
      if (myId == null) return;

      bool isShieldedToday = _dailyRecords.values.any((r) => r.isShielded);
      if (isShieldedToday) {
        await _habitService.removeShieldFromDate(myId, _selectedDate);
      }

      final bool wasCompleted = _dailyRecords[habitId]?.completat ?? false;
      final existingComment = _dailyRecords[habitId]?.comentari;

      await _habitService.processProgressUpdate(
        habitId: habitId,
        date: _selectedDate,
        valorProgres: valorProgres,
        completat: completat,
        comentari: existingComment,
      );

      final habit = _habits.firstWhere((h) => h.id == habitId);
      if (habit.isGroup) {
        await loadGroupDetails(habitId);
      }

      if (completat && !wasCompleted) {
        await _achievementService.updateProgress(myId, 'completatHabits50', 1);
      } else if (!completat && wasCompleted) {
        await _achievementService.updateProgress(myId, 'completatHabits50', -1);
      }

      final now = DateTime.now();
      bool isToday = _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      if (completat && !wasCompleted && isToday) {
        final myId = _habitService.currentUserId;
        if (myId != null) {
          await _missionService.updateProgress(myId, 'habits', 1.0, habitId);

          await loadDataForDate(_selectedDate);

          final habitsAvui = filteredHabits;
          if (habitsAvui.isNotEmpty) {
            bool totsComplets = habitsAvui.every((h) => _dailyRecords[h.id]?.completat ?? false);
            if (totsComplets) {
              await _missionService.updateProgress(myId, 'perfect_day', 1.0, 'perfect_${now.day}${now.month}');
            }
          }
        }
      }

      await loadDataForDate(_selectedDate);

      final habitsDeLaData = filteredHabits;
      bool diaEsPerfecteAra = habitsDeLaData.isNotEmpty &&
          habitsDeLaData.every((h) => _dailyRecords[h.id]?.completat ?? false);

      await _achievementService.syncPerfectDay(myId, _selectedDate, diaEsPerfecteAra);

      if (_habits.isNotEmpty) {
        final int maxRatxaGlobal = _habits.map((h) => h.millorRatxa).reduce((a, b) => a > b ? a : b);
        await _achievementService.setAbsoluteProgress(myId, 'ratxa50', maxRatxaGlobal);
      }

      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } catch (e) {
      debugPrint("Error al Provider: $e");
      rethrow;
    }
  }

  Future<void> createHabit(HabitModel habit) async {
    await _habitService.createHabit(habit);

    final myId = _habitService.currentUserId;
    if (myId != null) {
      await _achievementService.updateProgress(myId, 'primerHabit', 1);
    }

    await loadDataForDate(_selectedDate);

    if (myId != null && habit.isGroup) {
      final int totalGrupals = _habits.where((h) => h.isGroup).length;
      await _achievementService.setAbsoluteProgress(myId, 'grupalsUnits5', totalGrupals);
    }

    await loadAllTimeData();
  }

  Future<void> updateHabit(HabitModel habit) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _habitService.updateHabit(habit);

      await loadDataForDate(_selectedDate);

      final myId = _habitService.currentUserId;
      if (myId != null && _habits.isNotEmpty) {
        final int maxRatxaGlobal = _habits.map((h) => h.millorRatxa).reduce((a, b) => a > b ? a : b);
        await _achievementService.setAbsoluteProgress(myId, 'ratxa50', maxRatxaGlobal);
      }

      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bool eraGrupal = _habits.any((h) => h.id == habitId && h.isGroup);

      stopListeningToAllGroups();
      await _habitService.deleteHabit(habitId);
      await loadDataForDate(_selectedDate);
      listenToAllVisibleGroups();

      final myId = _habitService.currentUserId;
      if (myId != null && eraGrupal) {
        final int totalGrupals = _habits.where((h) => h.isGroup).length;
        await _achievementService.setAbsoluteProgress(myId, 'grupalsUnits5', totalGrupals);
      }

      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  HabitStats getStats({required bool isMensual, String? habitId, String? categoryId, bool useGroupData = false,}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    List<HabitRecordModel> sourceRecords;

    if (useGroupData) {
      sourceRecords = isMensual ? _groupAggregatedMonthlyRecords : _groupAggregatedAllTimeRecords;
    } else {
      sourceRecords = isMensual ? _monthlyRecords : _allTimeRecords;
    }

    if (isMensual) {
      start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      DateTime lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
      end = (_focusedMonth.year == now.year && _focusedMonth.month == now.month) ? now : lastDay;
    } else {
      if (_habits.isEmpty) return HabitStats();
      List<HabitModel> habitsToCheck = _habits;
      if (habitId != null) {
        habitsToCheck = _habits.where((h) => h.id == habitId).toList();
      }
      if (habitsToCheck.isEmpty) return HabitStats();
      start = habitsToCheck.map((h) => h.dataInici).reduce((a, b) => a.isBefore(b) ? a : b);
      end = now;
    }

    return _habitService.calculateStats(
      allHabits: _habits,
      records: sourceRecords,
      startDate: start,
      endDate: end,
      selectedHabitId: habitId,
    );
  }

  Future<void> useStreakShield(String userId, DateTime date, String inventoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _habitService.applyShield(userId, date, inventoryId);
      await loadDataForDate(date);
      await loadAllTimeData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isDateShielded(DateTime date) async {
    return await _habitService.isDateShielded(date);
  }

  Future<void> joinGroup(String userId, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _habitService.joinGroup(userId, code);
      await loadDataForDate(_selectedDate);

      final int totalGrupals = _habits.where((h) => h.isGroup).length;
      await _achievementService.setAbsoluteProgress(userId, 'grupalsUnits5', totalGrupals);

    } catch (e) {
      if (e == 'invalid_code') {
        throw 'invalid_code';
      }
      throw 'error_generic';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupDetails(String habitId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _habitService.getGroupInviteCode(habitId),
        _habitService.getGroupMembers(habitId, _selectedDate),
        _habitService.getGroupTotalProgress(habitId, _selectedDate),
      ]);
      _currentInviteCode = results[0] as String?;
      _currentGroupMembers = results[1] as List<HabitGroupMember>;
      _currentGroupTotalProgress = results[2] as double;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void listenToGroupChanges(String habitId) {
    _groupSubscription?.unsubscribe();
    _groupSubscription = _habitService.subscribeToGroupChanges(habitId, () {
      loadGroupDetails(habitId);
    });
  }

  void stopListeningToGroupChanges() {
    _groupSubscription?.unsubscribe();
    _groupSubscription = null;
  }

  Future<void> leaveGroup(String habitId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final myId = _habitService.currentUserId;
      if (myId == null) return;

      stopListeningToGroupChanges();
      await _habitService.leaveGroupHabit(habitId, myId);
      stopListeningToAllGroups();

      await loadDataForDate(_selectedDate);
      listenToAllVisibleGroups();

      final int totalGrupals = _habits.where((h) => h.isGroup).length;
      await _achievementService.setAbsoluteProgress(myId, 'grupalsUnits5', totalGrupals);

      await loadMonthlyData(_focusedMonth);
      await loadAllTimeData();
    } catch (e) {
      debugPrint("Error al abandonar grup: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupStatistics(String habitId, DateTime month) async {
    _isLoading = true;
    notifyListeners();

    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0);

      final allRecords = await _habitService.getGroupRecordsForRange(habitId, start, end);
      final allTimeGroupRecords = await _habitService.getAllRecordsForHabit(habitId);

      final habit = _habits.firstWhere((h) => h.id == habitId);
      _groupAggregatedMonthlyRecords = _aggregateRecords(allRecords, habit.valorObjectiu);
      _groupAggregatedAllTimeRecords = _aggregateRecords(allTimeGroupRecords, habit.valorObjectiu);

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HabitRecordModel> _aggregateRecords(List<HabitRecordModel> records, double valorObjectiu) {
    final Map<String, HabitRecordModel> aggregated = {};

    for (var r in records) {
      final dateKey = r.dataRegistre.toIso8601String().split('T').first;
      if (aggregated.containsKey(dateKey)) {
        final existing = aggregated[dateKey]!;
        final nouProgres = existing.valorProgres + r.valorProgres;
        aggregated[dateKey] = existing.copyWith(
          valorProgres: nouProgres,
          completat: nouProgres >= valorObjectiu,
        );
      } else {
        aggregated[dateKey] = r.copyWith(
            completat: r.valorProgres >= valorObjectiu
        );
      }
    }
    return aggregated.values.toList();
  }
}