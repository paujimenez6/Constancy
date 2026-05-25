class MissionModel {
  final String id;
  final String titolClau;
  final String descripcioClau;
  final int recompensaXp;
  final int recompensaMonedes;
  final double objectiu;
  final String tipus;

  MissionModel({
    required this.id,
    required this.titolClau,
    required this.descripcioClau,
    required this.recompensaXp,
    required this.recompensaMonedes,
    required this.objectiu,
    required this.tipus,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? '',
      titolClau: json['titol_clau'] ?? '',
      descripcioClau: json['desc_clau'] ?? '',
      recompensaXp: json['recompensa_xp'] ?? 0,
      recompensaMonedes: json['recompensa_monedes'] ?? 0,
      objectiu: (json['objectiu'] as num?)?.toDouble() ?? 0.0,
      tipus: json['tipus'] ?? '',
    );
  }
}

class UserMissionModel {
  final String id;
  final double progresActual;
  final bool completada;
  final bool reclamada;
  final MissionModel definicio;

  UserMissionModel({
    required this.id,
    required this.progresActual,
    required this.completada,
    required this.reclamada,
    required this.definicio,
  });

  factory UserMissionModel.fromJson(Map<String, dynamic> json) {
    return UserMissionModel(
      id: json['id'] ?? '',
      progresActual: (json['progres_actual'] as num?)?.toDouble() ?? 0.0,
      completada: json['completada'] ?? false,
      reclamada: json['reclamada'] ?? false,
      definicio: MissionModel.fromJson(json['missions_definicions'] ?? {}),
    );
  }

  double get percentatge => definicio.objectiu > 0
      ? (progresActual / definicio.objectiu).clamp(0.0, 1.0)
      : 0.0;
}