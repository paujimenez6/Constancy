enum TipusPrivacitat { public, privat, amics }

class UserModel {
  final String id;
  final String nickname;
  final String nom;
  final String cognom;
  final String correu;
  final String? imatgePerfil;
  final int puntsXP;
  final int monedes;
  final TipusPrivacitat configuracioPrivacitat;
  final DateTime dataRegistre;
  final bool dobleFactorActiu;
  final String? token;
  final DateTime? multiplicadorXpFins;
  final DateTime? imantMonedesFins;
  final String? locale;

  UserModel({
    required this.id,
    required this.nickname,
    required this.nom,
    required this.cognom,
    required this.correu,
    this.imatgePerfil,
    this.puntsXP = 0,
    this.monedes = 0,
    this.configuracioPrivacitat = TipusPrivacitat.privat,
    required this.dataRegistre,
    this.dobleFactorActiu = false,
    this.token,
    this.multiplicadorXpFins,
    this.imantMonedesFins,
    this.locale,
  });

  UserModel copyWith({
    String? nickname,
    String? nom,
    String? cognom,
    String? correu,
    String? imatgePerfil,
    int? puntsXP,
    int? monedes,
    TipusPrivacitat? configuracioPrivacitat,
    DateTime? dataRegistre,
    bool? dobleFactorActiu,
    String? token,
    DateTime? multiplicadorXpFins,
    DateTime? imantMonedesFins,
    String? locale,
  }) {
    return UserModel(
      id: id,
      nickname: nickname ?? this.nickname,
      nom: nom ?? this.nom,
      cognom: cognom ?? this.cognom,
      correu: correu ?? this.correu,
      imatgePerfil: imatgePerfil ?? this.imatgePerfil,
      puntsXP: puntsXP ?? this.puntsXP,
      monedes: monedes ?? this.monedes,
      configuracioPrivacitat: configuracioPrivacitat ?? this.configuracioPrivacitat,
      dataRegistre: dataRegistre ?? this.dataRegistre,
      dobleFactorActiu: dobleFactorActiu ?? this.dobleFactorActiu,
      token: token ?? this.token,
      multiplicadorXpFins: multiplicadorXpFins ?? this.multiplicadorXpFins,
      imantMonedesFins: imantMonedesFins ?? this.imantMonedesFins,
      locale: locale ?? this.locale,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Usuari',
      nom: json['nom'] ?? '',
      cognom: json['cognom'] ?? '',
      correu: json['correu'] ?? '',
      imatgePerfil: json['imatge_perfil'],
      puntsXP: json['punts_xp'] ?? 0,
      monedes: json['monedes'] ?? 0,
      configuracioPrivacitat: TipusPrivacitat.values.firstWhere(
            (e) => e.toString().split('.').last == json['configuracio_privacitat'], orElse: () => TipusPrivacitat.privat,
      ),
      dataRegistre: json['data_registre'] != null ? DateTime.parse(json['data_registre']) : DateTime.now(),
      dobleFactorActiu: json['doble_factor_actiu'] ?? false,
      token: json['token'],
      multiplicadorXpFins: json['multiplicador_xp_fins'] != null ? DateTime.parse(json['multiplicador_xp_fins']) : null,
      imantMonedesFins: json['imant_monedes_fins'] != null ? DateTime.parse(json['imant_monedes_fins']) : null,
      locale: json['locale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'nom': nom,
      'cognom': cognom,
      'correu': correu,
      'imatge_perfil': imatgePerfil,
      'punts_xp': puntsXP,
      'monedes': monedes,
      'configuracio_privacitat': configuracioPrivacitat.toString().split('.').last,
      'data_registre': dataRegistre.toIso8601String(),
      'doble_factor_actiu': dobleFactorActiu,
      'token': token,
      'multiplicador_xp_fins': multiplicadorXpFins?.toIso8601String(),
      'imant_monedes_fins': imantMonedesFins?.toIso8601String(),
      'locale': locale,
    };
  }

  bool get isMultiplierActive => multiplicadorXpFins != null && multiplicadorXpFins!.isAfter(DateTime.now());

  bool get isCoinMagnetActive => imantMonedesFins != null && imantMonedesFins!.isAfter(DateTime.now());
}