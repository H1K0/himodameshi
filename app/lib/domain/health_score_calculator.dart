import 'freq_response_stats.dart';
import '/data/test_models.dart';

/// Результат расчёта Health Score
class HealthScoreResult {
  final double? score; // null если ни один тест не завершён
  final bool isPartial; // true если расчёт по части тестов
  final List<String> missingTests; // список незавершённых тестов

  const HealthScoreResult({
    this.score,
    this.isPartial = false,
    this.missingTests = const [],
  });

  bool get hasScore => score != null;
}

class HealthScoreCalculator {
  // Константы
  static const double continuityOkThreshold = 5.0; // Ω
  static const double continuityWarningThreshold = 50.0; // Ω

  static const double cmrrFailThreshold = 40.0; // дБ
  static const double cmrrOkThreshold = 60.0; // дБ

  // Базовые веса для разных типов кабелей
  static const Map<CableType, Map<String, double>> baseWeights = {
    CableType.xlr: {'continuity': 0.35, 'cmrr': 0.35, 'freq': 0.30},
    CableType.jackTrs: {'continuity': 0.35, 'cmrr': 0.35, 'freq': 0.30},
    CableType.jackTs: {'continuity': 0.60, 'cmrr': 0.00, 'freq': 0.40},
  };

  // --------------------------------------------------------------------------
  // Главный метод расчёта Health Score
  // --------------------------------------------------------------------------
  static HealthScoreResult calculate({
    required CableType cableType,
    required List<Map<String, dynamic>> continuityConductors,
    required double? cmrrDb,
    required List<double>? freqResponseValues,
    // Флаги, какие тесты были запрошены пользователем
    required bool continuityRun,
    required bool cmrrRun,
    required bool freqRun,
  }) {
    // 1. Проверка катастрофических условий
    for (final conductor in continuityConductors) {
      final status = conductor['s'] as String;
      if (status == 'open' || status == 'short') {
        return const HealthScoreResult(
          score: 0.0,
          isPartial: false,
          missingTests: [],
        );
      }
    }

    // 2. Определяем, какие тесты завершены (имеют данные)
    final bool continuityCompleted = continuityConductors.isNotEmpty;
    final bool cmrrCompleted = cableType.supportsCmrr && cmrrDb != null;
    final bool freqCompleted =
        freqResponseValues != null && freqResponseValues.isNotEmpty;

    // 4. Проверяем, был ли запущен хотя бы один тест
    final bool anyRun = continuityRun || cmrrRun || freqRun;
    if (!anyRun) {
      // Ни один тест не был запущен
      return const HealthScoreResult(
        score: null,
        isPartial: false,
        missingTests: [],
      );
    }

    // 5. Для запущенных тестов проверяем, какие завершены
    final List<String> missingTests = [];
    if (continuityRun && !continuityCompleted) missingTests.add('целостность');
    if (cmrrRun && !cmrrCompleted) missingTests.add('CMRR');
    if (freqRun && !freqCompleted) missingTests.add('АЧХ');

    // 6. Если нет ни одного завершённого теста среди запущенных
    final bool hasAnyCompleted =
        (continuityRun && continuityCompleted) ||
        (cmrrRun && cmrrCompleted) ||
        (freqRun && freqCompleted);

    if (!hasAnyCompleted) {
      return HealthScoreResult(
        score: null,
        isPartial: false,
        missingTests: missingTests,
      );
    }

    // 7. Расчёт суб-скоров
    final double sc = _calculateContinuityScore(continuityConductors);
    final double sm = (cmrrCompleted) ? _calculateCmrrScore(cmrrDb) : 0.0;
    final double sf = (freqCompleted)
        ? _calculateFreqResponseScore(freqResponseValues)
        : 0.0;

    // 8. Перераспределение весов только для завершённых тестов
    final baseW = baseWeights[cableType]!;

    // Собираем веса только для тех тестов, которые были ЗАПУЩЕНЫ И ЗАВЕРШЕНЫ
    final Map<String, double> activeWeights = {};
    if (continuityRun && continuityCompleted) {
      activeWeights['continuity'] = baseW['continuity']!;
    }
    if (cmrrRun && cmrrCompleted) activeWeights['cmrr'] = baseW['cmrr']!;
    if (freqRun && freqCompleted) activeWeights['freq'] = baseW['freq']!;

    // Сумма базовых весов активных тестов
    final double totalWeight = activeWeights.values.fold(
      0.0,
      (sum, w) => sum + w,
    );

    // Нормированные веса
    final double wcNorm = (activeWeights['continuity'] ?? 0.0) / totalWeight;
    final double wmNorm = (activeWeights['cmrr'] ?? 0.0) / totalWeight;
    final double wfNorm = (activeWeights['freq'] ?? 0.0) / totalWeight;

    // 9. Взвешенная сумма
    double healthScore = 0.0;
    healthScore += wcNorm * sc;
    healthScore += wmNorm * sm;
    healthScore += wfNorm * sf;

    // 10. Округление и ограничение
    final double finalScore = (healthScore * 10).roundToDouble() / 10;
    final bool isPartial = missingTests.isNotEmpty;

    return HealthScoreResult(
      score: finalScore,
      isPartial: isPartial,
      missingTests: missingTests,
    );
  }

  // --------------------------------------------------------------------------
  // Суб-скор целостности (Sc)
  // --------------------------------------------------------------------------
  static double _calculateContinuityScore(
    List<Map<String, dynamic>> conductors,
  ) {
    if (conductors.isEmpty) return 0.0;

    double sumScores = 0.0;
    for (final conductor in conductors) {
      final double r = (conductor['r'] as num).toDouble();
      sumScores += _singleContinuityScore(r);
    }
    return sumScores / conductors.length;
  }

  static double _singleContinuityScore(double r) {
    if (r < 5.0) {
      double score = 100.0 - 4.0 * r;
      return score.clamp(0.0, 100.0);
    } else {
      double score = 80.0 - (8.0 / 9.0) * (r - 5.0);
      return score.clamp(0.0, 100.0);
    }
  }

  // --------------------------------------------------------------------------
  // Суб-скор CMRR (Sm)
  // --------------------------------------------------------------------------
  static double _calculateCmrrScore(double cmrrDb) {
    if (cmrrDb < 20.0) return 0.0;
    if (cmrrDb < 60.0) {
      return 2.0 * (cmrrDb - 20.0);
    } else {
      final score = 80.0 + (cmrrDb - 60.0);
      return score.clamp(0.0, 100.0);
    }
  }

  // --------------------------------------------------------------------------
  // Суб-скор АЧХ (Sf)
  // --------------------------------------------------------------------------
  static double _calculateFreqResponseScore(List<double> v) {
    final stats = FreqResponseStats.fromValues(v);
    if (stats.noSignal) return 0.0;

    double sfAudio = 100.0 - 14.0 * stats.peak - 6.0 * stats.sigma;
    sfAudio = sfAudio.clamp(0.0, 100.0);

    final hfValues = v.sublist(27, 30);
    double peakHf = 0.0;
    for (final val in hfValues) {
      final absVal = val.abs();
      if (absVal > peakHf) peakHf = absVal;
    }

    double penaltyHf = (peakHf - 3.0) * 4.0;
    penaltyHf = penaltyHf.clamp(0.0, double.infinity);

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
    if (peak <= 1.0 && sigma <= 1.0) return 'excellent';
    if (peak <= 3.0 && sigma <= 3.0) return 'ok';
    return 'fail';
  }
}
