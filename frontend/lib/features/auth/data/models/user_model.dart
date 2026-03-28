enum TipusPrivacitat { public, privat, amics }

class UserModel {
  final String nickname;
  final String nom;
  final String cognom;
  final String correu;
  final String? imatgePerfil;
  final int puntsXP;
  final int nivellXP;
  final int monedes;
  final TipusPrivacitat configuracioPrivacitat;
  final DateTime dataRegistre;
  final bool dobleFactorActiu;
  final String? token;

  UserModel({
    required this.nickname,
    required this.nom,
    required this.cognom,
    required this.correu,
    this.imatgePerfil,
    this.puntsXP = 0,
    this.nivellXP = 1,
    this.monedes = 0,
    this.configuracioPrivacitat = TipusPrivacitat.public,
    required this.dataRegistre,
    this.dobleFactorActiu = false,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickname: json['nickname'],
      nom: json['nom'],
      cognom: json['cognom'],
      correu: json['correu'],
      imatgePerfil: json['imatge_perfil'],
      puntsXP: json['punts_xp'] ?? 0,
      nivellXP: json['nivell_xp'] ?? 1,
      monedes: json['monedes'] ?? 0,
      configuracioPrivacitat: TipusPrivacitat.values.firstWhere(
            (e) => e.toString().split('.').last == json['configuracio_privacitat'],
        orElse: () => TipusPrivacitat.public,
      ),
      dataRegistre: DateTime.parse(json['data_registre']),
      dobleFactorActiu: json['doble_factor_actiu'] ?? false,
      token: json['token'],
    );
  }
}