import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../persistence/repositories/habit_repository.dart';
import '../models/chart_data_model.dart';
import '../models/habit_group_member_model.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';
import '../models/stats_model.dart';
import '../models/user_model.dart';

class HabitService {
  final HabitRepository _habitRepository;

  HabitService(this._habitRepository);

  String? get currentUserId => _habitRepository.currentUserId;
  Future<List<HabitModel>> getHabits() => _habitRepository.getHabits();
  Future<void> deleteHabit(String habitId) => _habitRepository.deleteHabit(habitId);
  Future<List<HabitRecordModel>> getRecordsForDate(DateTime date) => _habitRepository.getRecordsForDate(date);
  Future<List<HabitRecordModel>> getRecordsForRange(DateTime start, DateTime end) => _habitRepository.getRecordsForRange(start, end);
  Future<List<HabitRecordModel>> getAllRecords() => _habitRepository.getAllRecords();

  Future<HabitModel> createHabit(HabitModel habit) async {
    if (habit.isGroup) {
      final code = generateInviteCode();
      return await _habitRepository.createGroupHabit(habit, code);
    }
    return await _habitRepository.createHabit(habit);
  }

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return "CONST-$code";
  }

  Future<void> joinGroup(String userId, String code) async {
    await _habitRepository.joinByCode(userId, code);
  }

  List<HabitModel> getArchivedHabits(List<HabitModel> allHabits) {
    return allHabits.where((h) => h.arxivat).toList();
  }

  Future<void> updateHabit(HabitModel habit) async {
    final oldHabits = await _habitRepository.getHabits();
    final oldHabit = oldHabits.firstWhere((h) => h.id == habit.id);

    await _habitRepository.updateHabit(habit);

    if (oldHabit.valorObjectiu != habit.valorObjectiu) {
      await _syncRecordsWithNewGoal(habit);
    }

    await recalculateAndSaveStreaks(habit.id);
  }

  Future<void> _syncRecordsWithNewGoal(HabitModel habit) async {
    final records = await _habitRepository.getAllRecordsForHabit(habit.id);

    for (var record in records) {
      bool araEstaCompletat = record.valorProgres >= habit.valorObjectiu;

      if (record.completat != araEstaCompletat) {
        await _habitRepository.saveRecord(
          habitId: habit.id,
          date: record.dataRegistre,
          valorProgres: record.valorProgres,
          completat: araEstaCompletat,
          comentari: record.comentari,
        );
      }
    }
  }

  List<HabitModel> filterHabitsForDate(List<HabitModel> allHabits, DateTime date, {bool includeArchived = false}) {
    return allHabits.where((h) {
      final sel = DateTime(date.year, date.month, date.day);
      final inici = DateTime(h.dataInici.year, h.dataInici.month, h.dataInici.day);

      bool esValidInici = sel.isAtSameMomentAs(inici) || sel.isAfter(inici);
      bool esValidFi = h.dataFi == null ||
          sel.isAtSameMomentAs(DateTime(h.dataFi!.year, h.dataFi!.month, h.dataFi!.day)) ||
          sel.isBefore(DateTime(h.dataFi!.year, h.dataFi!.month, h.dataFi!.day));

      if (!esValidInici || !esValidFi) return false;
      if (!includeArchived && h.arxivat) return false;

      if (h.periodeObjectiu == PeriodeObjectiu.diari) return true;
      if (h.periodeObjectiu == PeriodeObjectiu.setmanal) return sel.weekday == inici.weekday;
      if (h.periodeObjectiu == PeriodeObjectiu.mensual) {
        int diaObjectiu = inici.day;
        int ultimDiaMesActual = DateTime(sel.year, sel.month + 1, 0).day;
        return sel.day == (diaObjectiu > ultimDiaMesActual ? ultimDiaMesActual : diaObjectiu);
      }
      return false;
    }).toList();
  }

  Future<void> processProgressUpdate({
    required String habitId,
    required DateTime date,
    required double valorProgres,
    required bool completat,
    String? comentari,
  }) async {
    await _habitRepository.saveRecord(
      habitId: habitId,
      date: date,
      valorProgres: valorProgres,
      completat: completat,
      comentari: comentari,
    );
  }

  Future<void> recalculateAndSaveStreaks(String habitId) async {
    final records = await _habitRepository.getAllRecordsForHabit(habitId);
    final habits = await _habitRepository.getHabits();
    final habit = habits.firstWhere((h) => h.id == habitId);

    final completedDates = records
        .where((r) => r.completat || r.isShielded)
        .map((r) => DateTime(r.dataRegistre.year, r.dataRegistre.month, r.dataRegistre.day))
        .toList();
    completedDates.sort((a, b) => b.compareTo(a));

    if (completedDates.isEmpty) {
      await _habitRepository.updateHabitStreaks(habitId, 0, 0);
      return;
    }

    int maxStreak = 1;
    int currentMax = 1;
    for (int i = 0; i < completedDates.length - 1; i++) {
      if (_isConsecutive(completedDates[i], completedDates[i + 1], habit.periodeObjectiu)) {
        currentMax++;
      } else {
        currentMax = 1;
      }
      if (currentMax > maxStreak) maxStreak = currentMax;
    }

    int actualStreak = 0;
    if (_isStreakAlive(completedDates.first, habit.periodeObjectiu)) {
      actualStreak = 1;
      for (int i = 0; i < completedDates.length - 1; i++) {
        if (_isConsecutive(completedDates[i], completedDates[i + 1], habit.periodeObjectiu)) {
          actualStreak++;
        } else {
          break;
        }
      }
    }
    await _habitRepository.updateHabitStreaks(habitId, actualStreak, maxStreak);
  }

  bool _isConsecutive(DateTime newer, DateTime older, PeriodeObjectiu periode) {
    if (periode == PeriodeObjectiu.diari) return newer.difference(older).inDays == 1;
    if (periode == PeriodeObjectiu.setmanal) return newer.difference(older).inDays == 7;
    int monthsDiff = (newer.year - older.year) * 12 + (newer.month - older.month);
    return monthsDiff == 1;
  }

  bool _isStreakAlive(DateTime lastCompleted, PeriodeObjectiu periode) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (periode == PeriodeObjectiu.diari) return lastCompleted.isAtSameMomentAs(today) || lastCompleted.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
    if (periode == PeriodeObjectiu.setmanal) return lastCompleted.isAtSameMomentAs(today) || today.difference(lastCompleted).inDays <= 7;
    int monthsDiff = (today.year - lastCompleted.year) * 12 + (today.month - lastCompleted.month);
    return monthsDiff <= 1;
  }

  bool canSeeHabits({
    required String currentUserId,
    required String targetUserId,
    required TipusPrivacitat privacitat,
    required bool isFollowing,
  }) {
    if (currentUserId == targetUserId) return true;

    if (privacitat == TipusPrivacitat.public) return true;

    if (privacitat == TipusPrivacitat.amics) return isFollowing;

    return false;
  }

  List<String> getMonthLabels(BuildContext context) {
    final dateFormat = DateFormat.MMM(Intl.getCurrentLocale());
    return List.generate(12, (i) =>
        dateFormat.format(DateTime(2024, i + 1, 1)).replaceAll('.', '')
    );
  }

  List<ChartDataPoint> getChartData({
    required List<HabitRecordModel> records,
    required bool isMensual,
    required DateTime referenceDate,
    HabitModel? selectedHabit,
    String? selectedCategory,
    bool isCumulative = false,
  }) {
    final now = DateTime.now();
    final bool isCurrentMonth = referenceDate.year == now.year && referenceDate.month == now.month;

    if (isMensual) {
      final lastDayOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0).day;
      double runningTotal = 0.0;

      final int limitDay = isCurrentMonth ? now.day : lastDayOfMonth;

      return List.generate(limitDay, (index) {
        final day = index + 1;

        final dayRecords = records.where((r) {
          final date = r.dataRegistre;
          return date.day == day &&
              date.month == referenceDate.month &&
              date.year == referenceDate.year &&
              (selectedHabit == null || r.habitId == selectedHabit.id);
        }).toList();

        double currentValue = 0;
        if (selectedHabit == null) {
          currentValue = dayRecords.where((r) => r.completat).length.toDouble();
        } else {
          currentValue = dayRecords.fold(0.0, (sum, r) => sum + r.valorProgres);
        }

        if (isCumulative) {
          runningTotal += currentValue;
          return ChartDataPoint(x: day.toDouble(), y: runningTotal);
        } else {
          return ChartDataPoint(x: day.toDouble(), y: currentValue);
        }
      });
    } else {
      double runningTotal = 0.0;
      final int limitMonth = (referenceDate.year == now.year) ? now.month : 12;

      return List.generate(limitMonth, (index) {
        final month = index + 1;
        final monthRecords = records.where((r) {
          final date = r.dataRegistre;
          return date.month == month &&
              date.year == referenceDate.year &&
              (selectedHabit == null || r.habitId == selectedHabit.id);
        }).toList();

        double currentValue = 0;
        if (selectedHabit == null) {
          currentValue = monthRecords.where((r) => r.completat).length.toDouble();
        } else {
          currentValue = monthRecords.fold(0.0, (sum, r) => sum + r.valorProgres);
        }

        if (isCumulative) {
          runningTotal += currentValue;
          return ChartDataPoint(x: month.toDouble(), y: runningTotal);
        } else {
          return ChartDataPoint(x: month.toDouble(), y: currentValue);
        }
      });
    }
  }

  List<String> getUniqueCategories(List<HabitModel> habits) {
    return habits
        .map((h) => h.grup ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getLocalizedMonths() {
    final locale = Intl.getCurrentLocale();
    final DateFormat formatter = DateFormat.MMMM(locale);

    return List.generate(12, (i) {
      final date = DateTime(2026, i + 1, 1);
      String month = formatter.format(date);

      if (month.length >= 3) {
        month = month.substring(0, 3);
      } else {
        month = month.padRight(3);
      }

      return month[0].toUpperCase() + month.substring(1).toLowerCase();
    });
  }

  HabitStats calculateStats({
    required List<HabitModel> allHabits,
    required List<HabitRecordModel> records,
    required DateTime startDate,
    required DateTime endDate,
    String? selectedHabitId,
  }) {
    int totalExpected = 0;
    int totalCompleted = 0;
    int perfectDays = 0;
    int activeDays = 0;
    double totalAccumulatedValue = 0;

    Map<String, int> habitCurrentStreaks = {};
    Map<String, int> habitMaxStreaks = {};

    final int totalDaysInRange = endDate.difference(startDate).inDays + 1;
    final List<HabitModel> habitsToAnalyze = selectedHabitId != null
        ? allHabits.where((h) => h.id == selectedHabitId).toList()
        : allHabits;

    for (int i = 0; i < totalDaysInRange; i++) {
      DateTime date = startDate.add(Duration(days: i));

      var expectedOnDate = filterHabitsForDate(allHabits, date, includeArchived: true);
      if (selectedHabitId != null) {
        expectedOnDate = expectedOnDate.where((h) => h.id == selectedHabitId).toList();
      }

      if (expectedOnDate.isNotEmpty) activeDays++;

      int completedOnDateCount = 0;

      for (var h in habitsToAnalyze) {
        bool expectedToday = expectedOnDate.any((eh) => eh.id == h.id);
        if (!expectedToday) continue;

        var recordToday = records.where((r) =>
        r.habitId == h.id &&
            r.dataRegistre.year == date.year &&
            r.dataRegistre.month == date.month &&
            r.dataRegistre.day == date.day
        ).toList();

        bool completedToday = recordToday.isNotEmpty && (recordToday.first.valorProgres >= h.valorObjectiu || recordToday.first.isShielded);

        if (recordToday.isNotEmpty) totalAccumulatedValue += recordToday.first.valorProgres;

        if (completedToday) {
          completedOnDateCount++;
          habitCurrentStreaks[h.id] = (habitCurrentStreaks[h.id] ?? 0) + 1;
          if ((habitCurrentStreaks[h.id] ?? 0) > (habitMaxStreaks[h.id] ?? 0)) {
            habitMaxStreaks[h.id] = habitCurrentStreaks[h.id]!;
          }
        } else {
          habitCurrentStreaks[h.id] = 0;
        }
      }

      totalExpected += expectedOnDate.length;
      totalCompleted += completedOnDateCount;

      if (expectedOnDate.isNotEmpty && completedOnDateCount >= expectedOnDate.length) {
        perfectDays++;
      }
    }

    HabitModel? starHabit;
    int maxStreakFound = 0;
    int currentStreakFound = 0;

    if (selectedHabitId != null) {
      maxStreakFound = habitMaxStreaks[selectedHabitId] ?? 0;
      currentStreakFound = habitCurrentStreaks[selectedHabitId] ?? 0;
    } else if (allHabits.isNotEmpty) {
      habitMaxStreaks.forEach((id, streak) {
        if (streak > maxStreakFound) maxStreakFound = streak;
      });
      if (maxStreakFound > 0) {
        String starId = habitMaxStreaks.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        starHabit = allHabits.firstWhere((h) => h.id == starId);
      }
    }

    return HabitStats(
      totalExpected: totalExpected,
      totalCompleted: totalCompleted,
      completionPercentage: totalExpected > 0 ? (totalCompleted / totalExpected) * 100 : 0.0,
      perfectDays: perfectDays,
      dailyAverage: activeDays > 0 ? totalCompleted / activeDays : 0.0,
      starHabit: starHabit,
      maxStreak: maxStreakFound,
      currentStreak: currentStreakFound,
      totalAccumulatedValue: totalAccumulatedValue,
    );
  }

  Future<List<HabitModel>> getHabitsByUserId(String targetUserId) async {
    final habits = await _habitRepository.getHabitsByUserId(targetUserId);
    return habits;
  }

  Future<void> applyShield(String userId, DateTime date, String inventoryId) async {
    await _habitRepository.applyStreakShield(userId, date, inventoryId);

    final habits = await _habitRepository.getHabits();
    for (var h in habits) {
      if (!h.arxivat) {
        await recalculateAndSaveStreaks(h.id);
      }
    }
  }

  Future<void> removeShieldFromDate(String userId, DateTime date) async {
    await _habitRepository.unshieldDate(userId, date);

    final habits = await _habitRepository.getHabits();
    for (var h in habits) {
      if (!h.arxivat) {
        await recalculateAndSaveStreaks(h.id);
      }
    }
  }

  Future<bool> isDateShielded(DateTime date) async {
    final records = await getRecordsForDate(date);
    return records.any((r) => r.isShielded);
  }

  Future<String?> getGroupInviteCode(String habitId) {
    return _habitRepository.getGroupInviteCode(habitId);
  }

  Future<List<HabitGroupMember>> getGroupMembers(String habitId, DateTime date) {
    return _habitRepository.getGroupMembers(habitId, date);
  }

  Future<double> getGroupTotalProgress(String habitId, DateTime date) {
    return _habitRepository.getGroupTotalProgress(habitId, date);
  }

  dynamic subscribeToGroupChanges(String habitId, Function onUpdate) {
    return _habitRepository.subscribeToGroupChanges(habitId, onUpdate);
  }

  Future<void> leaveGroupHabit(String habitId, String userId) async {
    await _habitRepository.leaveGroupHabit(habitId, userId);
  }

  Future<List<HabitRecordModel>> getGroupRecordsForRange(String habitId, DateTime start, DateTime end) async{
    return await _habitRepository.getGroupRecordsForRange(habitId, start, end);
  }

  Future<List<HabitRecordModel>> getAllRecordsForHabit(String habitId) async {
    return await _habitRepository.getAllRecordsForHabit(habitId);
  }
}