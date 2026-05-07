enum LeagueResultType { promoted, demoted, stayed }

class LeagueModel {
  final String id;
  final String nomLliga;
  final int nivellLliga;
  final String color;
  final DateTime dataInici;
  final DateTime dataFi;

  LeagueModel({
    required this.id,
    required this.nomLliga,
    required this.nivellLliga,
    required this.color,
    required this.dataInici,
    required this.dataFi,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'],
      nomLliga: json['nom_lliga'] ?? '',
      nivellLliga: json['nivell_lliga'] ?? 1,
      color: json['color'] ?? '#FFD700',
      dataInici: DateTime.parse(json['data_inici']),
      dataFi: DateTime.parse(json['data_fi']),
    );
  }

  String getLocalizedName(dynamic strings) {
    return getLocalizedLevelName(nivellLliga, strings, fallback: nomLliga);
  }

  static String getLocalizedLevelName(int level, dynamic strings, {String? fallback}) {
    switch (level) {
      case 1: return strings.leagueBronze;
      case 2: return strings.leagueSilver;
      case 3: return strings.leagueGold;
      case 4: return strings.leagueRuby;
      case 5: return strings.leagueEmerald;
      case 6: return strings.leagueDiamond;
      default: return fallback ?? level.toString();
    }
  }

  bool get isMaxLevel => nivellLliga == 6;

  bool get isMinLevel => nivellLliga == 1;

  String getTimeRemaining(dynamic strings) {
    final ara = DateTime.now();
    final diferencia = dataFi.difference(ara);

    if (diferencia.isNegative) {
      return strings.leagueResultFinished;
    }

    if (diferencia.inDays >= 1) {
      return strings.timeLeftDays(diferencia.inDays);
    } else if (diferencia.inHours >= 1) {
      final hores = diferencia.inHours;
      final minuts = diferencia.inMinutes.remainder(60);
      return strings.timeLeftHoursMinutes(hores, minuts);
    } else {
      final minuts = diferencia.inMinutes;
      return strings.timeLeftMinutes(minuts > 0 ? minuts : 1);
    }
  }
}

class LeagueParticipationModel {
  final String userId;
  final String leagueId;
  final int xpTemporada;
  final int posicioActual;
  final String? nickname;
  final String? imatgePerfil;
  final String? nom;
  final String? cognom;
  final int puntsXP;
  final int monedes;

  LeagueParticipationModel({
    required this.userId,
    required this.leagueId,
    required this.xpTemporada,
    required this.posicioActual,
    this.nickname,
    this.imatgePerfil,
    this.nom,
    this.cognom,
    this.puntsXP = 0,
    this.monedes = 0,
  });

  factory LeagueParticipationModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return LeagueParticipationModel(
      userId: json['user_id'],
      leagueId: json['league_id'],
      xpTemporada: json['xp_temporada'] ?? 0,
      posicioActual: json['posicio_actual'] ?? 1,
      nickname: profile?['nickname'],
      imatgePerfil: profile?['imatge_perfil'],
      nom: profile?['nom'],
      cognom: profile?['cognom'],
      puntsXP: profile?['punts_xp'] ?? 0,
      monedes: profile?['monedes'] ?? 0,
    );
  }
}

class LeagueResultModel {
  final String id;
  final int nivellAnterior;
  final int nivellNou;
  final int posicioFinal;

  LeagueResultModel({
    required this.id,
    required this.nivellAnterior,
    required this.nivellNou,
    required this.posicioFinal,
  });

  factory LeagueResultModel.fromJson(Map<String, dynamic> json) {
    return LeagueResultModel(
      id: json['id'],
      nivellAnterior: json['nivell_anterior'],
      nivellNou: json['nivell_nou'],
      posicioFinal: json['posicio_final'],
    );
  }

  LeagueResultType get type {
    if (nivellNou > nivellAnterior) return LeagueResultType.promoted;
    if (nivellNou < nivellAnterior) return LeagueResultType.demoted;
    return LeagueResultType.stayed;
  }
}