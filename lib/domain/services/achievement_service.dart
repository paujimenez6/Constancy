import 'dart:math';
import '../../persistence/repositories/achievement_repository.dart';

class AchievementService {
  final AchievementRepository _repository;

  AchievementService(this._repository);

  int generateRandomXP() {
    final random = Random();
    return (random.nextInt(19) * 5) + 10;
  }

  Future<void> updateProgress(String userId, String condicio, int increment) async {
    await _repository.updateProgress(userId, condicio, increment);
  }
}