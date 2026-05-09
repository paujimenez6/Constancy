class ShopItemModel {
  final String id;
  final String nomClau;
  final String descClau;
  final String tipusEfecte;
  final double valorEfecte;
  final int preu;
  final String icona;

  ShopItemModel({
    required this.id,
    required this.nomClau,
    required this.descClau,
    required this.tipusEfecte,
    required this.valorEfecte,
    required this.preu,
    required this.icona,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      nomClau: json['nom_clau'],
      descClau: json['desc_clau'],
      tipusEfecte: json['tipus_efecte'],
      valorEfecte: (json['valor_efecte'] as num).toDouble(),
      preu: json['preu'] as int,
      icona: json['icona'],
    );
  }
}