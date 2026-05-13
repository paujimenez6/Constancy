class HabitGroupMember {
  final String userId;
  final String nickname;
  final String? imatgePerfil;
  final double progresAcumulat;
  final double progresAvui;
  final bool esAdministrador;

  HabitGroupMember({
    required this.userId,
    required this.nickname,
    this.imatgePerfil,
    required this.progresAcumulat,
    required this.progresAvui,
    required this.esAdministrador,
  });

  factory HabitGroupMember.fromJson(Map<String, dynamic> json) {
    return HabitGroupMember(
      userId: json['user_id'] ?? '',
      nickname: json['nickname'] ?? 'Usuari',
      imatgePerfil: json['imatge_perfil'],
      progresAcumulat: (json['progres_acumulat'] ?? 0).toDouble(),
      progresAvui: (json['progres_avui'] ?? 0).toDouble(),
      esAdministrador: json['es_administrador'] ?? false,
    );
  }
}