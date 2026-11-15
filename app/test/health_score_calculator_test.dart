import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/health_score_calculator.dart';
import 'package:app/data/test_models.dart';

void main() {
  group('HealthScoreCalculator', () {
    test('Идеальный XLR-кабель должен получать близко к 100 баллам', () {
      // Arrange
      final conductors = [
        {'r': 0.0, 's': 'ok'}, // Идеальное сопротивление для 100 баллов
        {'r': 0.0, 's': 'ok'},
        {'r': 0.0, 's': 'ok'},
      ];
      final cmrrDb = 80.0;
      final freqValues = List.filled(30, 0.0);

      // Act
      final result = HealthScoreCalculator.calculate(
        cableType: CableType.xlr,
        continuityConductors: conductors,
        cmrrDb: cmrrDb,
        freqResponseValues: freqValues,
        continuityRun: true,
        cmrrRun: true,
        freqRun: true,
      );

      // Assert
      expect(result.score, 100.0);
      expect(result.isPartial, false);
      expect(result.missingTests, isEmpty);
    });

    test('Кабель с обрывом (open) должен получать 0 баллов', () {
      // Arrange
      final conductors = [
        {'r': 0.8, 's': 'ok'},
        {'r': 99999.0, 's': 'open'}, // Обрыв!
        {'r': 0.7, 's': 'ok'},
      ];

      // Act
      final result = HealthScoreCalculator.calculate(
        cableType: CableType.xlr,
        continuityConductors: conductors,
        cmrrDb: 70.0,
        freqResponseValues: List.filled(30, 0.0),
        continuityRun: true,
        cmrrRun: true,
        freqRun: true,
      );

      // Assert
      expect(result.score, 0.0);
    });

    test('Если CMRR запрошен, но данных нет, тест помечается как неполный', () {
      // Arrange
      final conductors = [
        {'r': 1.0, 's': 'ok'},
      ];

      // Act
      final result = HealthScoreCalculator.calculate(
        cableType: CableType.jackTs,
        continuityConductors: conductors,
        cmrrDb: null,
        freqResponseValues: null,
        continuityRun: true,
        cmrrRun: true, // <-- ЗАПРОШЕН
        freqRun: false, // <-- НЕ ЗАПРОШЕН
      );

      // Assert
      expect(
        result.isPartial,
        true,
      ); // Теперь true, так как CMRR запрошен, но не выполнен
      expect(result.missingTests, contains('CMRR'));
      expect(result.score, isNotNull);
    });
  });
}
