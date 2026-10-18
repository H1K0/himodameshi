import 'dart:math';

/// Статистика АЧХ в аудиодиапазоне.
///
/// Используется и в HealthScoreCalculator (расчёт суб-скора S_f),
/// и в presentation (определение статуса и передача данных в LLM).
///
/// Границы аудиодиапазона — индексы 3..26 в частотной таблице
/// (24 Гц – 16959 Гц). Инфразвук (0..2) и сверхзвук (27..29)
/// в аудиоанализ не входят.
class FreqResponseStats {
  /// Пик |v| в аудиодиапазоне, дБ.
  final double peak;

  /// Среднеквадратичное отклонение в аудиодиапазоне, дБ.
  final double sigma;

  /// true, если хотя бы одна точка содержит сентинел -99.0
  /// (пропадание сигнала).
  final bool noSignal;

  const FreqResponseStats({
    required this.peak,
    required this.sigma,
    required this.noSignal,
  });

  /// Границы аудиодиапазона в частотной таблице (индексы sublist).
  static const int audioStartIndex = 3;
  static const int audioEndIndex = 27; // эксклюзивный

  /// Сентинел «нет сигнала» в протоколе.
  static const double noSignalSentinel = -99.0;

  /// Считает статистику по массиву отклонений (30 точек).
  ///
  /// Бросает [ArgumentError], если список короче [audioEndIndex] точек —
  /// это нарушение протокола, не нормальная ситуация.
  factory FreqResponseStats.fromValues(List<double> values) {
    if (values.length < audioEndIndex) {
      throw ArgumentError(
        'FreqResponseStats: ожидается минимум $audioEndIndex точек, '
            'получено ${values.length}',
      );
    }

    if (values.any((v) => v <= noSignalSentinel)) {
      return const FreqResponseStats(peak: 0.0, sigma: 0.0, noSignal: true);
    }

    final audio = values.sublist(audioStartIndex, audioEndIndex);

    double peak = 0.0;
    double sumSquares = 0.0;
    for (final v in audio) {
      final absV = v.abs();
      if (absV > peak) peak = absV;
      sumSquares += v * v;
    }

    final sigma = sqrt(sumSquares / audio.length);

    return FreqResponseStats(
      peak: peak,
      sigma: sigma,
      noSignal: false,
    );
  }
}