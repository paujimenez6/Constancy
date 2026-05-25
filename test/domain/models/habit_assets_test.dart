import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/habit_assets.dart';

void main() {
  group('HabitAssets Test', () {
    test('hexToColor converteix correctament un string hexadecimal a Color', () {
      final color = HabitAssets.hexToColor('#F44336');
      expect(color.value, 0xFFF44336);
    });

    test('getIconByName retorna la icona correcta si la clau existeix', () {
      final icona = HabitAssets.getIconByName('fitness_center');
      expect(icona, Icons.fitness_center_rounded);
    });

    test('getIconByName retorna la icona per defecte (star_rounded) si la clau no existeix', () {
      final icona = HabitAssets.getIconByName('icona_inventada_que_no_existeix');
      expect(icona, Icons.star_rounded);
    });

    test('Les llistes de colors i icones no estan buides', () {
      expect(HabitAssets.colors, isNotEmpty);
      expect(HabitAssets.icons, isNotEmpty);
    });
  });
}