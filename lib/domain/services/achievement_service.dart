import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../persistence/repositories/achievement_repository.dart';
import '../models/achievement_model.dart';

class AchievementService {
  final AchievementRepository _repository;

  AchievementService(this._repository);

  int generateRandomXP() {
    final random = Random();
    return (random.nextInt(19) * 5) + 10;
  }

  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    return await _repository.getUserAchievements(userId);
  }

  RealtimeChannel subscribeToAchievementChanges(String userId, Function onUpdate) {
    return _repository.subscribeToAchievementChanges(userId, onUpdate);
  }

  Future<void> updateProgress(String userId, String condicio, int increment) async {
    await _repository.updateProgress(userId, condicio, increment);
  }

  Future<void> setAbsoluteProgress(String userId, String condicio, int value) async {
    await _repository.setAbsoluteProgress(userId, condicio, value);
  }

  Future<bool> markAsClaimed(String achievementId, String userId, int xp) async {
    return await _repository.markAsClaimed(achievementId, userId, xp);
  }

  Future<void> syncPerfectDay(String userId, DateTime date, bool isPerfect) async {
    await _repository.syncPerfectDay(userId, date, isPerfect);
  }
}