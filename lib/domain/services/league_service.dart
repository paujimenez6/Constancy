import '../../persistence/repositories/league_repository.dart';
import '../models/league_model.dart';

class LeagueService {
  final LeagueRepository _leagueRepository;
  LeagueService(this._leagueRepository);

  Future<Map<String, dynamic>?> getUserLeague(String userId) =>
      _leagueRepository.getCurrentUserLeague(userId);

  Future<List<LeagueParticipationModel>> getRanking(String leagueId) async {
    final data = await _leagueRepository.getLeagueRanking(leagueId);
    return data.map((json) => LeagueParticipationModel.fromJson(json)).toList();
  }

  Stream<List<LeagueParticipationModel>> getRankingStream(String leagueId) {
    return _leagueRepository.listenToRanking(leagueId).map((list) =>
        list.map((json) => LeagueParticipationModel.fromJson(json)).toList());
  }

  Future<Map<String, dynamic>?> getPendingResult(String userId) {
    return _leagueRepository.getPendingResult(userId);
  }

  Future<void> markResultAsSeen(String resultId) {
    return _leagueRepository.markResultAsSeen(resultId);
  }

  Stream<LeagueResultModel?> listenForSeasonResults(String userId) {
    return _leagueRepository.listenToNewResults(userId).map((list) {
      final pending = list.where((r) => r['vists'] == false).toList();
      if (pending.isEmpty) return null;
      return LeagueResultModel.fromJson(pending.first);
    });
  }

  Stream<void> onUserLeagueChanged(String userId) {
    return _leagueRepository.listenToUserParticipation(userId);
  }
}