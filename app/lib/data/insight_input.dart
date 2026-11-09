import 'test_models.dart';

/// Входные данные для LLM-генератора комментария.
/// Группирует параметры по тестам — если тест не запускался,
/// соответствующее поле равно null.
class InsightInput {
  final CableType cableType;
  final int? healthScore;

  final ContinuityInsight? continuity;
  final CmrrInsight? cmrr;
  final FreqInsight? freq;

  const InsightInput({
    required this.cableType,
    this.healthScore,
    this.continuity,
    this.cmrr,
    this.freq,
  });
}

/// Данные теста целостности.
class ContinuityInsight {
  final double min;
  final double max;

  const ContinuityInsight({required this.min, required this.max});
}

/// Данные теста CMRR.
class CmrrInsight {
  final double valueDb;

  const CmrrInsight({required this.valueDb});
}

/// Данные теста АЧХ.
class FreqInsight {
  final double? peak;
  final double? sigma;
  final bool noSignal;

  const FreqInsight({this.peak, this.sigma, this.noSignal = false});
}
