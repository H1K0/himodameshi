import 'dart:math';

import '/data/test_models.dart';

class HealthScoreCalculator {
  // Константы
  static const double continuityOkThreshold = 5.0;      // Ω
  static const double continuityWarningThreshold = 50.0; // Ω

  static const double cmrrFailThreshold = 40.0;   // дБ
  static const double cmrrOkThreshold = 60.0;     // дБ

  // Веса для разных типов кабелей
  static const Map<CableType, Map<String, double>> weights = {
    CableType.xlr: {'continuity': 0.35, 'cmrr': 0.35, 'freq': 0.30},
    CableType.jackTrs: {'continuity': 0.35, 'cmrr': 0.35, 'freq': 0.30},
    CableType.jackTs: {'continuity': 0.60, 'cmrr': 0.00, 'freq': 0.40},
  };

  // --------------------------------------------------------------------------
  // Главный метод расчёта Health Score
  // --------------------------------------------------------------------------
  static double calculate({
    required CableType cableType,
    required List<Map<String, dynamic>> continuityConductors,
    required double? cmrrDb,
    required List<double>? freqResponseValues,
  }) {
    // 1. Проверка катастрофических условий
    for (final conductor in continuityConductors) {
      final status = conductor['s'] as String;
      if (status == 'open' || status == 'short') {
        return 0;
      }
    }

    // 2. Расчёт суб-скоров
    final double sc = _calculateContinuityScore(continuityConductors);
    final double sm = (cableType.supportsCmrr && cmrrDb != null)
        ? _calculateCmrrScore(cmrrDb)
        : 0.0;
    final double sf = (freqResponseValues != null && freqResponseValues.isNotEmpty)
        ? _calculateFreqResponseScore(freqResponseValues)
        : 100.0; // Если АЧХ не измерялась, считаем идеальной

    // 3. Взвешенная сумма
    final w = weights[cableType]!;
    double healthScore = 0.0;
    healthScore += w['continuity']! * sc;
    healthScore += w['cmrr']! * sm;
    healthScore += w['freq']! * sf;

    // 4. Округление и ограничение
    return (healthScore * 10).roundToDouble() / 10;
  }

  // --------------------------------------------------------------------------
  // Суб-скор целостности (Sc)
  // --------------------------------------------------------------------------
  static double _calculateContinuityScore(List<Map<String, dynamic>> conductors) {
    if (conductors.isEmpty) return 0.0;

    double sumScores = 0.0;
    for (final conductor in conductors) {
      final double r = (conductor['r'] as num).toDouble();
      sumScores += _singleContinuityScore(r);
    }
    return sumScores / conductors.length;
  }

  static double _singleContinuityScore(double r) {
    // r < 5 Ω (зона ok)
    if (r < 5.0) {
      double score = 100.0 - 4.0 * r;
      return score.clamp(0.0, 100.0);
    }
    // r >= 5 Ω (зона warning и выше)
    else {
      // s = max(0, 80 - (8/9)*(r - 5))
      // При r = 5 → 80
      // При r = 50 → 40
      // При r = 95 → 0
      double score = 80.0 - (8.0 / 9.0) * (r - 5.0);
      return score.clamp(0.0, 100.0);
    }
  }

  // --------------------------------------------------------------------------
  // Суб-скор CMRR (Sm)
  // --------------------------------------------------------------------------
  static double _calculateCmrrScore(double cmrrDb) {
    // d < 20 → 0
    if (cmrrDb < 20.0) return 0.0;

    // 20 ≤ d < 60 → 2*(d - 20)
    if (cmrrDb < 60.0) {
      return 2.0 * (cmrrDb - 20.0);
    }

    // d ≥ 60 → min(100, 80 + (d - 60))
    else {
      final score = 80.0 + (cmrrDb - 60.0);
      return score.clamp(0.0, 100.0);
    }
  }

  // --------------------------------------------------------------------------
  // Суб-скор АЧХ (Sf)
  // --------------------------------------------------------------------------
  static double _calculateFreqResponseScore(List<double> v) {
    // Проверка на сентинел -99.0 (пропадание сигнала)
    if (v.any((value) => value <= -99.0)) return 0.0;

    // Индексы частот:
    // v[0-2] — 10-20 Гц (не участвуют в расчёте)
    // v[3-26] — 20 Гц – 20 кГц (аудиодиапазон)
    // v[27-29] — выше 20 кГц (сверхзвуковая зона)

    // 1. Расчёт для аудиодиапазона (20 Гц – 20 кГц)
    final audioValues = v.sublist(3, 27); // индексы 3..26
    double peak = 0.0;
    double sumSquares = 0.0;

    for (final val in audioValues) {
      final absVal = val.abs();
      if (absVal > peak) peak = absVal;
      sumSquares += val * val;
    }

    final double sigma = sqrt((sumSquares / audioValues.length));

    // Sf_audio = max(0, 100 - 14*peak - 6*sigma)
    double sfAudio = 100.0 - 14.0 * peak - 6.0 * sigma;
    sfAudio = sfAudio.clamp(0.0, 100.0);

    // 2. ВЧ-штраф (20 кГц – 40 кГц)
    final hfValues = v.sublist(27, 30); // индексы 27..29
    double peakHf = 0.0;
    for (final val in hfValues) {
      final absVal = val.abs();
      if (absVal > peakHf) peakHf = absVal;
    }

    // penalty_hf = max(0, (peak_hf - 3) * 4)
    double penaltyHf = (peakHf - 3.0) * 4.0;
    penaltyHf = penaltyHf.clamp(0.0, double.infinity);

    // 3. Итоговый суб-скор
    double sf = sfAudio - penaltyHf;
    return sf.clamp(0.0, 100.0);
  }

  // --------------------------------------------------------------------------
  // Вспомогательные методы для получения статусов (для UI)
  // --------------------------------------------------------------------------
  static String getContinuityStatus(double r) {
    if (r < 5.0) return 'ok';
    if (r < 50.0) return 'warning';
    return 'fail';
  }

  static String getCmrrStatus(double cmrrDb) {
    if (cmrrDb > 60.0) return 'excellent';
    if (cmrrDb >= 40.0) return 'ok';
    return 'fail';
  }

  static String getFreqResponseStatus(double peak, double sigma) {
    // excellent: peak ≤ 1.0 дБ и sigma ≤ 1.0 дБ
    if (peak <= 1.0 && sigma <= 1.0) return 'excellent';
    // ok: peak ≤ 3.0 дБ и sigma ≤ 3.0 дБ
    if (peak <= 3.0 && sigma <= 3.0) return 'ok';
    return 'fail';
  }
}