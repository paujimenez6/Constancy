import 'package:flutter/material.dart';
import '../../domain/models/achievement_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../persistence/repositories/achievement_repository.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;
  final AchievementRepository _repository;

  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  AchievementProvider(this._service, this._repository);

  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> loadUserAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _achievements = await _repository.getUserAchievements(userId);
    } catch (e) {
      debugPrint("Error al carregar assoliments al Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> claimAchievementReward(String achievementId, String userId) async {
    final int xp = _service.generateRandomXP();

    final bool success = await _repository.markAsClaimed(achievementId, userId, xp);

    if (success) {
      await loadUserAchievements(userId);
      return xp;
    }
    return null;
  }

  Future<void> trackAction(String userId, String condicio, {int increment = 1}) async {
    try {
      await _service.updateProgress(userId, condicio, increment);
    } catch (e) {
      debugPrint("Error al registrar acció de l'assoliment ($condicio): $e");
    }
  }
}