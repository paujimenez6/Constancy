class HabitRecordModel {
  final String id;
  final String habitId;
  final String userId;
  final DateTime dataRegistre;
  final bool completat;
  final double valorProgres;
  final String? comentari;
  final bool isShielded;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitRecordModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.dataRegistre,
    this.completat = false,
    this.valorProgres = 0.0,
    this.comentari,
    this.isShielded = false,
    required this.createdAt,
    required this.updatedAt,
  });

  HabitRecordModel copyWith({
    bool? completat,
    double? valorProgres,
    String? comentari,
    bool? isShielded,
    bool updateComentari = false,
  }) {
    return HabitRecordModel(
      id: id,
      habitId: habitId,
      userId: userId,
      dataRegistre: dataRegistre,
      completat: completat ?? this.completat,
      valorProgres: valorProgres ?? this.valorProgres,
      comentari: updateComentari ? comentari : (comentari ?? this.comentari),
      isShielded: isShielded ?? this.isShielded,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory HabitRecordModel.fromJson(Map<String, dynamic> json) {
    return HabitRecordModel(
      id: json['id'] ?? '',
      habitId: json['habit_id'] ?? '',
      userId: json['user_id'] ?? '',
      dataRegistre: DateTime.parse(json['data_registre']),
      completat: json['completat'] ?? false,
      valorProgres: (json['valor_progres'] ?? 0).toDouble(),
      comentari: json['comentari'],
      isShielded: json['is_shielded'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}