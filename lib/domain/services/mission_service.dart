import '../../persistence/repositories/mission_repository.dart';
import '../models/mission_model.dart';

class MissionService {
  final MissionRepository _repository;

  MissionService(this._repository);

  Future<List<UserMissionModel>> fetchTodayMissions(String userId) async {
    await _repository.assignarMissionsDiaries(userId);

    final data = await _repository.getUserMissions(userId);
    return data.map((json) => UserMissionModel.fromJson(json)).toList();
  }

  Future<void> updateProgress(String userId, String type, double amount, String itemId) async {
    await _repository.incrementMissionProgress(userId, type, amount, itemId);
  }

  Future<void> claimReward(UserMissionModel userMission, String userId) async {
    if (userMission.completada && !userMission.reclamada) {
      await _repository.claimMissionReward(userMission.id, userId);
    } else {
      throw Exception("Missió no apta per reclamar");
    }
  }

  Stream<List<UserMissionModel>> listenToMissions(String userId) {
    return _repository.listenToUserMissions(userId).map((list) {
      return list.map((json) => UserMissionModel.fromJson(json)).toList();
    });
  }

  Future<void> executeReroll(String userId, String userMissionId, String inventoryId) async {
    await _repository.rerollMission(userId, userMissionId, inventoryId);
  }
}