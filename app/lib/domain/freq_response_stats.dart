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

    return FreqResponseStats(peak: peak, sigma: sigma, noSignal: false);
  }
}

class FreqMetrics {
  final String bandwidth3db; // Например, "22.4" или "> 40"
  final String valueAt20khz; // Например, "-2.1"
  final String unevenness; // Например, "±0.4"

  const FreqMetrics({
    required this.bandwidth3db,
    required this.valueAt20khz,
    required this.unevenness,
  });

  factory FreqMetrics.fromValues(List<double>? values) {
    if (values == null || values.length < 30) {
      return const FreqMetrics(
        bandwidth3db: '—',
        valueAt20khz: '—',
        unevenness: '—',
      );
    }

    // 1. Считаем полосу -3 дБ
    // Ищем первую точку (начиная с аудио-диапазона), где значение падает до -3
    double bandwidth = 40.0; // Если не упало, значит тянется до 40 кГц
    bool foundDrop = false;

    final List<double> freqTable = [
      10.0,
      13.0,
      18.0,
      24.0,
      31.0,
      42.0,
      56.0,
      74.0,
      99.0,
      131.0,
      175.0,
      232.0,
      309.0,
      412.0,
      548.0,
      730.0,
      1000.0,
      1293.0,
      1721.0,
      2291.0,
      3050.0,
      4060.0,
      5404.0,
      7192.0,
      9574.0,
      12742.0,
      16959.0,
      22573.0,
      30043.0,
      40000.0,
    ];

    // Проверяем только аудиодиапазон (с 20 Гц до 20 кГц)
    for (int i = 3; i <= 26; i++) {
      if (values[i] <= -3.0) {
        bandwidth = freqTable[i] / 1000; // Переводим в кГц
        foundDrop = true;
        break;
      }
    }

    // 2. Значение на 20 кГц (интерполяция между 16959 и 22573)
    // Логарифмическая интерполяция точнее для аудио, но для простоты можно линейную
    final double v26 = values[26];
    final double v27 = values[27];
    // Коэффициент: насколько 20к ближе к 22.5к
    final double t = (20000 - 16959) / (22573 - 16959);
    final double v20k = v26 + (v27 - v26) * t;

    // 3. Неравномерность (максимальный модуль отклонения в аудио-зоне 20Гц-17кГц)
    double peak = 0.0;
    for (int i = 3; i < 30; i++) {
      if (values[i].abs() > peak) peak = values[i].abs();
    }

    return FreqMetrics(
      bandwidth3db: foundDrop ? bandwidth.toStringAsFixed(1) : '> 40',
      valueAt20khz: v20k.toStringAsFixed(1),
      unevenness: '±${peak.toStringAsFixed(1)}',
    );
  }
}
