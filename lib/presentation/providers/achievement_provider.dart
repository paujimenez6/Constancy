import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/achievement_model.dart';
import '../../domain/services/achievement_service.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;

  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  RealtimeChannel? _achievementsSubscription;

  AchievementProvider(this._service);

  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> loadUserAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _achievements = await _service.getUserAchievements(userId);
    } catch (e) {
      debugPrint("Error al carregar assoliments al Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void listenToAchievementChanges(String userId) {
    stopListeningToAchievementChanges();
    _achievementsSubscription = _service.subscribeToAchievementChanges(userId, () async {
      await loadUserAchievements(userId);
    });
  }

  void stopListeningToAchievementChanges() {
    _achievementsSubscription?.unsubscribe();
    _achievementsSubscription = null;
  }

  Future<int?> claimAchievementReward(String achievementId, String userId) async {
    final int xp = _service.generateRandomXP();

    final bool success = await _service.markAsClaimed(achievementId, userId, xp);

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

  @override
  void dispose() {
    stopListeningToAchievementChanges();
    super.dispose();
  }

  Future<void> setAbsoluteProgress(String userId, String condicio, int value) async {
    await _service.setAbsoluteProgress(userId, condicio, value);
  }
}