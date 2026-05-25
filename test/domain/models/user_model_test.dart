import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/user_model.dart';

void main() {
  group('UserModel Test', () {
    test('fromJson i toJson funcionen correctament', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u1', nickname: 'Pau', nom: 'Pau', cognom: 'J', correu: 'p@p.com',
        dataRegistre: now, configuracioPrivacitat: TipusPrivacitat.public,
      );

      final json = user.toJson();
      final userFromJson = UserModel.fromJson(json);

      expect(userFromJson.id, user.id);
      expect(userFromJson.configuracioPrivacitat, TipusPrivacitat.public);
    });

    test('isMultiplierActive i isCoinMagnetActive funcionen segons la data', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      final user = UserModel(
        id: '1', nickname: 'N', nom: 'N', cognom: 'C', correu: 'e@e.com',
        dataRegistre: DateTime.now(),
        multiplicadorXpFins: futureDate,
        imantMonedesFins: pastDate,
      );

      expect(user.isMultiplierActive, isTrue);
      expect(user.isCoinMagnetActive, isFalse);
    });

    test('copyWith crea nova instància amb valors canviats', () {
      final user = UserModel(id: '1', nickname: 'N', nom: 'N', cognom: 'C', correu: 'e@e.com', dataRegistre: DateTime.now());
      final updated = user.copyWith(nickname: 'NouNick');

      expect(updated.nickname, 'NouNick');
      expect(updated.nom, 'N');
    });
  });
}