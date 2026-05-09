import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/mission_model.dart';
import '../../domain/services/mission_service.dart';

class MissionProvider extends ChangeNotifier {
  final MissionService _service;

  List<UserMissionModel> _missions = [];
  bool _isLoading = false;

  MissionProvider(this._service);

  StreamSubscription? _missionsSubscription;
  List<UserMissionModel> get missions => _missions;
  bool get isLoading => _isLoading;

  void initMissionsListener(String userId) {
    _missionsSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _service.fetchTodayMissions(userId).then((_) {
      _missionsSubscription = _service.listenToMissions(userId).listen((updatedMissions) {
        _missions = updatedMissions;
        _isLoading = false;
        notifyListeners();
      });
    });
  }

  Future<void> loadMissions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _missions = await _service.fetchTodayMissions(userId);
    } catch (e) {
      debugPrint("Error carregant missions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notifyAction(String userId, String type, String itemId, {double amount = 1.0}) async {
    try {
      await _service.updateProgress(userId, type, amount, itemId);
    } catch (e) {
      debugPrint("Error actualitzant progrés missió: $e");
    }
  }

  Future<bool> claimMission(UserMissionModel mission, String userId, bool hasMultiplier) async {
    try {
      await _service.claimReward(mission, userId);

      double xpGuanyada = mission.definicio.recompensaXp.toDouble();
      if (hasMultiplier) {
        xpGuanyada *= 2;
      }

      await notifyAction(
          userId,
          'xp',
          'claim_${mission.id}',
          amount: xpGuanyada
      );
      return true;
    } catch (e) {
      debugPrint("Error al reclamar: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _missionsSubscription?.cancel();
    super.dispose();
  }

}