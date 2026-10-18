// data/mock_test_data_generator.dart
import 'dart:math';
import 'test_models.dart';

/// Генератор случайных результатов тестирования для mock-режима.
/// Используется для отладки UI без реального устройства.
class MockTestDataGenerator {
  static final Random _random = Random();

  // --------------------------------------------------------------------------
  // ЦЕЛОСТНОСТЬ
  // --------------------------------------------------------------------------

  /// Генерирует результат теста целостности.
  ///
  /// Возвращает:
  /// ```
  /// {
  ///   'conductors': [
  ///     {'name': 'tip', 'r': 0.85, 's': 'ok'},
  ///     {'name': 'sleeve', 'r': 0.72, 's': 'ok'},
  ///   ],
  ///   'status': 'ok',
  /// }
  /// ```
  static Map<String, dynamic> generateContinuity(CableType cableType) {
    final List<String> conductorNames = _getConductorNames(cableType);
    final List<Map<String, dynamic>> conductors = [];

    for (final name in conductorNames) {
      final conductor = _generateSingleConductor();
      conductors.add({
        'name': name,
        'r': conductor['r'],
        's': conductor['s'],
      });
    }

    final overallStatus = _getOverallContinuityStatus(conductors);

    return {
      'conductors': conductors,
      'status': overallStatus,
    };
  }

  static List<String> _getConductorNames(CableType type) {
    switch (type) {
      case CableType.xlr:
        return ['pin1', 'pin2', 'pin3'];
      case CableType.jackTrs:
        return ['tip', 'ring', 'sleeve'];
      case CableType.jackTs:
        return ['tip', 'sleeve'];
    }
  }

  /// Генерирует один проводник с учётом вероятностей аномалий:
  /// 90% — норма (0.3–5 Ω), 5% — warning (5–50 Ω),
  /// 3% — open (99999.0), 2% — short (0.01)
  static Map<String, dynamic> _generateSingleConductor() {
    final roll = _random.nextDouble();

    if (roll < 0.03) {
      // Open
      return {'r': 99999.0, 's': 'open'};
    } else if (roll < 0.05) {
      // Short
      return {'r': 0.01, 's': 'short'};
    } else if (roll < 0.10) {
      // Warning: 5–50 Ω
      final r = 5.0 + _random.nextDouble() * 45.0;
      return {'r': double.parse(r.toStringAsFixed(2)), 's': 'warning'};
    } else {
      // Normal: 0.3–5 Ω
      final r = 0.3 + _random.nextDouble() * 4.7;
      return {'r': double.parse(r.toStringAsFixed(2)), 's': 'ok'};
    }
  }

  static String _getOverallContinuityStatus(List<Map<String, dynamic>> conductors) {
    bool hasOpen = false;
    bool hasShort = false;
    bool hasWarning = false;

    for (final c in conductors) {
      final s = c['s'] as String;
      if (s == 'open') {hasOpen = true;}
      else if (s == 'short') {hasShort = true;}
      else if (s == 'warning') {hasWarning = true;}
    }

    if (hasOpen || hasShort) return 'fail';
    if (hasWarning) return 'warning';
    return 'ok';
  }

  // --------------------------------------------------------------------------
  // CMRR
  // --------------------------------------------------------------------------

  /// Генерирует CMRR (20–80 дБ):
  /// 50% — excellent (60–80), 35% — ok (40–60), 15% — fail (20–40)
  static double generateCmrr() {
    final roll = _random.nextDouble();
    final double value;

    if (roll < 0.15) {
      // fail: 20–40 дБ
      value = 20.0 + _random.nextDouble() * 20.0;
    } else if (roll < 0.50) {
      // ok: 40–60 дБ
      value = 40.0 + _random.nextDouble() * 20.0;
    } else {
      // excellent: 60–80 дБ
      value = 60.0 + _random.nextDouble() * 20.0;
    }

    return double.parse(value.toStringAsFixed(1));
  }

  // --------------------------------------------------------------------------
  // АЧХ
  // --------------------------------------------------------------------------

  /// Частотная таблица из ble-protocol.md (30 точек)
  static const List<double> freqTable = [
    10.0, 13.0, 18.0, 24.0, 31.0, 42.0, 56.0, 74.0, 99.0, 131.0,
    175.0, 232.0, 309.0, 412.0, 548.0, 730.0, 1000.0, 1293.0, 1721.0,
    2291.0, 3050.0, 4060.0, 5404.0, 7192.0, 9574.0, 12742.0, 16959.0,
    22573.0, 30043.0, 40000.0,
  ];

  static const int refIndex = 16; // 1000 Гц — опорная точка

  /// Генерирует АЧХ — 30 точек отклонения в дБ от опорного уровня.
  /// v[16] ≡ 0.0 по определению протокола.
  ///
  /// Профиль:
  ///   50% — excellent (peak 0–1 дБ)
  ///   35% — ok (peak 1–3 дБ)
  ///   15% — fail (peak 3–10 дБ)
  static List<double> generateFreqResponse() {
    final roll = _random.nextDouble();
    final double targetPeak;

    if (roll < 0.15) {
      // fail
      targetPeak = 3.0 + _random.nextDouble() * 7.0;
    } else if (roll < 0.50) {
      // ok
      targetPeak = 1.0 + _random.nextDouble() * 2.0;
    } else {
      // excellent
      targetPeak = _random.nextDouble() * 1.0;
    }

    return _buildFreqCurve(targetPeak);
  }

  /// Строит плавную кривую завала с логарифмической зависимостью от частоты.
  /// - на НЧ (< 1 кГц): небольшой шум ±0.1 дБ
  /// - на ВЧ (> 1 кГц): плавный завал, нормированный так, чтобы peak в аудио
  ///   диапазоне (индекс 26, 16959 Гц) был равен targetPeak
  static List<double> _buildFreqCurve(double targetPeak) {
    final double refFreq = freqTable[refIndex];              // 1000 Гц
    final double maxAudioFreq = freqTable[26];               // 16959 Гц
    final double logMax = log(maxAudioFreq / refFreq);       // log(16.959)

    final List<double> result = [];

    for (int i = 0; i < freqTable.length; i++) {
      if (i == refIndex) {
        result.add(0.0);
        continue;
      }

      final f = freqTable[i];

      if (f <= refFreq) {
        // НЧ зона — почти ровно + шум
        final noise = (_random.nextDouble() - 0.5) * 0.2;
        result.add(double.parse(noise.toStringAsFixed(2)));
      } else {
        // ВЧ зона — плавный завал
        final double factor = log(f / refFreq) / logMax;
        final double value = -targetPeak * factor;
        final noise = (_random.nextDouble() - 0.5) * 0.1;
        result.add(double.parse((value + noise).toStringAsFixed(2)));
      }
    }

    return result;
  }
}