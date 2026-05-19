import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../generated/l10n.dart';

class AchievementModel {
  final String id;
  final String icona;
  final String condicioCodi;
  final int valorObjectiu;
  final int progresActual;
  final bool completat;
  final DateTime? dataObtencio;
  final bool reclamat;

  AchievementModel({
    required this.id,
    required this.icona,
    required this.condicioCodi,
    required this.valorObjectiu,
    this.progresActual = 0,
    this.completat = false,
    this.dataObtencio,
    this.reclamat = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      icona: json['icona'] ?? 'star',
      condicioCodi: json['condicio_codi'] ?? '',
      valorObjectiu: json['valor_objectiu'] ?? 1,
      progresActual: json['progres_actual'] ?? 0,
      completat: json['completat'] ?? false,
      dataObtencio: json['data_obtencio'] != null ? DateTime.parse(json['data_obtencio']) : null,
      reclamat: json['reclamat'] ?? false,
    );
  }

  String getNom(BuildContext context) {
    final s = S.of(context);
    switch (condicioCodi) {
      case 'primerHabit': return s.achPrimerHabitTitle;
      case 'completatHabits50': return s.achCompletatHabits50Title;
      case 'ratxa50': return s.achRatxa50Title;
      case 'grupalsUnits5': return s.achGrupalsUnits5Title;
      case 'seguirAmics10': return s.achSeguirAmics10Title;
      case 'missionsCompletades50': return s.achMissionsCompletades50Title;
      case 'compresBotiga25': return s.achCompresBotiga25Title;
      case 'utilitzarInventari25': return s.achUtilitzarInventari25Title;
      case 'lligaOr': return s.achLligaOrTitle;
      case 'lligaDiamant': return s.achLligaDiamantTitle;
      case 'fotoPerfil': return s.achFotoPerfilTitle;
      case 'activarMfa': return s.achActivarMfaTitle;
      case 'acumularXp1000': return s.achAcumularXp1000Title;
      case 'acumularMonedes1000': return s.achAcumularMonedes1000Title;
      case 'diaPerfecte10': return s.achDiaPerfecte10Title;
      default: return '';
    }
  }

  String getDescripcio(BuildContext context) {
    final s = S.of(context);
    switch (condicioCodi) {
      case 'primerHabit': return s.achPrimerHabitDesc;
      case 'completatHabits50': return s.achCompletatHabits50Desc;
      case 'ratxa50': return s.achRatxa50Desc;
      case 'grupalsUnits5': return s.achGrupalsUnits5Desc;
      case 'seguirAmics10': return s.achSeguirAmics10Desc;
      case 'missionsCompletades50': return s.achMissionsCompletades50Desc;
      case 'compresBotiga25': return s.achCompresBotiga25Desc;
      case 'utilitzarInventari25': return s.achUtilitzarInventari25Desc;
      case 'lligaOr': return s.achLligaOrDesc;
      case 'lligaDiamant': return s.achLligaDiamantDesc;
      case 'fotoPerfil': return s.achFotoPerfilDesc;
      case 'activarMfa': return s.achActivarMfaDesc;
      case 'acumularXp1000': return s.achAcumularXp1000Desc;
      case 'acumularMonedes1000': return s.achAcumularMonedes1000Desc;
      case 'diaPerfecte10': return s.achDiaPerfecte10Desc;
      default: return '';
    }
  }

  String get dataFormatada => dataObtencio != null ? DateFormat.yMMMMd(Intl.getCurrentLocale()).format(dataObtencio!) : '';
}