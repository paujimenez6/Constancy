enum PeriodeObjectiu { diari, setmanal, mensual }

enum UnitatMesura { vegades, passos, m, km, ml, g, cal, seg, min, hr }

class HabitModel {
  final String id;
  final String userId;
  final String titol;
  final String? descripcio;
  final String? grup;
  final String icona;
  final String color;
  final PeriodeObjectiu periodeObjectiu;
  final double valorObjectiu;
  final UnitatMesura unitatMesura;
  final int ratxaActual;
  final int millorRatxa;
  final DateTime dataInici;
  final DateTime? dataFi;
  final bool recordatoris;
  final List<String> horesRecordatori;
  final bool arxivat;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.titol,
    this.descripcio,
    this.grup,
    required this.icona,
    required this.color,
    this.periodeObjectiu = PeriodeObjectiu.diari,
    this.valorObjectiu = 1.0,
    this.unitatMesura = UnitatMesura.vegades,
    this.ratxaActual = 0,
    this.millorRatxa = 0,
    required this.dataInici,
    this.dataFi,
    this.recordatoris = false,
    this.horesRecordatori = const [],
    this.arxivat = false,
    required this.createdAt,
  });

  HabitModel copyWith({
    String? titol,
    String? descripcio,
    String? grup,
    String? icona,
    String? color,
    PeriodeObjectiu? periodeObjectiu,
    double? valorObjectiu,
    UnitatMesura? unitatMesura,
    int? ratxaActual,
    int? millorRatxa,
    DateTime? dataInici,
    DateTime? dataFi,
    bool? recordatoris,
    List<String>? horesRecordatori,
    bool? arxivat,
  }) {
    return HabitModel(
      id: id,
      userId: userId,
      titol: titol ?? this.titol,
      descripcio: descripcio ?? this.descripcio,
      grup: grup ?? this.grup,
      icona: icona ?? this.icona,
      color: color ?? this.color,
      periodeObjectiu: periodeObjectiu ?? this.periodeObjectiu,
      valorObjectiu: valorObjectiu ?? this.valorObjectiu,
      unitatMesura: unitatMesura ?? this.unitatMesura,
      ratxaActual: ratxaActual ?? this.ratxaActual,
      millorRatxa: millorRatxa ?? this.millorRatxa,
      dataInici: dataInici ?? this.dataInici,
      dataFi: dataFi ?? this.dataFi,
      recordatoris: recordatoris ?? this.recordatoris,
      horesRecordatori: horesRecordatori ?? this.horesRecordatori,
      arxivat: arxivat ?? this.arxivat,
      createdAt: createdAt,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      titol: json['titol'] ?? '',
      descripcio: json['descripcio'],
      grup: json['grup'],
      icona: json['icona'] ?? 'star',
      color: json['color'] ?? '#000000',

      periodeObjectiu: PeriodeObjectiu.values.firstWhere(
            (e) => e.name == json['periode_objectiu'],
        orElse: () => PeriodeObjectiu.diari,
      ),

      valorObjectiu: (json['valor_objectiu'] ?? 1).toDouble(),

      unitatMesura: UnitatMesura.values.firstWhere(
            (e) => e.name == json['unitat_mesura'],
        orElse: () => UnitatMesura.vegades,
      ),

      ratxaActual: json['ratxa_actual'] ?? 0,
      millorRatxa: json['millor_ratxa'] ?? 0,
      dataInici: DateTime.parse(json['data_inici']),
      dataFi: json['data_fi'] != null ? DateTime.parse(json['data_fi']) : null,
      recordatoris: json['recordatoris'] ?? false,

      horesRecordatori: json['hores_recordatori'] != null
          ? List<String>.from(json['hores_recordatori'])
          : [],

      arxivat: json['arxivat'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titol': titol,
      'descripcio': descripcio,
      'grup': grup,
      'icona': icona,
      'color': color,
      'periode_objectiu': periodeObjectiu.name,
      'valor_objectiu': valorObjectiu,
      'unitat_mesura': unitatMesura.name,
      'data_inici': dataInici.toIso8601String().split('T').first, //Format YYYY-MM-DD
      'data_fi': dataFi?.toIso8601String().split('T').first,
      'recordatoris': recordatoris,
      'hores_recordatori': horesRecordatori,
      'arxivat': arxivat,
    };
  }
}