import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/league_model.dart';
import '../../domain/services/league_service.dart';

class LeagueProvider extends ChangeNotifier {
  final LeagueService _leagueService;
  StreamSubscription? _rankingSubscription;
  StreamSubscription? _participationSubscription;
  StreamSubscription? _resultsSubscription;

  LeagueModel? _currentLeague;
  List<LeagueParticipationModel> _ranking = [];
  LeagueResultModel? _pendingResult;
  bool _isLoading = false;

  LeagueProvider(this._leagueService);

  LeagueModel? get currentLeague => _currentLeague;
  List<LeagueParticipationModel> get ranking => _ranking;
  LeagueResultModel? get pendingResult => _pendingResult;
  bool get isLoading => _isLoading;

  void initRealtimeListeners(String userId) {
    _participationSubscription?.cancel();
    _participationSubscription = _leagueService.onUserLeagueChanged(userId).listen((_) {
      loadUserLeague(userId);
    });

    _resultsSubscription?.cancel();
    _resultsSubscription = _leagueService.listenForSeasonResults(userId).listen((result) {
      _pendingResult = result;
      notifyListeners();
    });
  }

  Future<void> loadUserLeague(String userId) async {
    if (_currentLeague == null) _isLoading = true;
    notifyListeners();

    try {
      final data = await _leagueService.getUserLeague(userId);
      if (data != null) {
        _currentLeague = LeagueModel.fromJson(data['lligues']);

        await _rankingSubscription?.cancel();
        _rankingSubscription = _leagueService.getRankingStream(_currentLeague!.id).listen((newList) {
          _ranking = newList;
          notifyListeners();
        });
      } else {
        _currentLeague = null;
        _ranking = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLeagueResults(String userId) async {
    final data = await _leagueService.getPendingResult(userId);
    if (data != null) {
      _pendingResult = LeagueResultModel.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> dismissResult() async {
    if (_pendingResult != null) {
      await _leagueService.markResultAsSeen(_pendingResult!.id);
      _pendingResult = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _rankingSubscription?.cancel();
    _participationSubscription?.cancel();
    _resultsSubscription?.cancel();
    super.dispose();
  }

  Future<LeagueModel?> loadAnyUserLeague(String userId) async {
    try {
      final data = await _leagueService.getUserLeague(userId);
      if (data != null) {
        return LeagueModel.fromJson(data['lligues']);
      }
      return null;
    } catch (e) {
      debugPrint("Error carregant lliga d'usuari extern: $e");
      return null;
    }
  }
}