import 'habit_model.dart';

class HabitStats {
  final int totalExpected;
  final int totalCompleted;
  final double completionPercentage;
  final int perfectDays;
  final double dailyAverage;
  final HabitModel? starHabit;
  final int maxStreak;
  final int currentStreak;
  final double totalAccumulatedValue;

  HabitStats({
    this.totalExpected = 0,
    this.totalCompleted = 0,
    this.completionPercentage = 0.0,
    this.perfectDays = 0,
    this.dailyAverage = 0.0,
    this.starHabit,
    this.maxStreak = 0,
    this.currentStreak = 0,
    this.totalAccumulatedValue = 0.0,
  });
}