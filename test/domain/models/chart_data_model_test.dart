import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/chart_data_model.dart';

void main() {
  group('ChartDataPoint Model Test', () {
    test('El constructor assigna els valors correctament', () {
      final punt = ChartDataPoint(x: 1.0, y: 5.5, label: 'Dilluns');

      expect(punt.x, 1.0);
      expect(punt.y, 5.5);
      expect(punt.label, 'Dilluns');
    });

    test('El constructor assigna un label buit per defecte', () {
      final punt = ChartDataPoint(x: 2.0, y: 3.0);

      expect(punt.label, '');
    });
  });
}