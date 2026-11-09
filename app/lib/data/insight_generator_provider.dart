import 'package:app/domain/insight_generator.dart';
import 'zai_insight_generator.dart';

/// Провайдер для получения текущей реализации InsightGenerator.
///
/// По умолчанию — ZaiInsightGenerator (Zhipu GLM).
/// Для переключения на Hub — заменить в одном месте.
/// Для тестов — использовать overrideWith().
class InsightGeneratorProvider {
  static InsightGenerator _instance = ZaiInsightGenerator();

  static InsightGenerator get instance => _instance;

  /// Заменить текущую реализацию (для тестов или перехода на Hub).
  static void overrideWith(InsightGenerator generator) {
    _instance = generator;
  }

  /// Сбросить к дефолтной реализации.
  static void reset() {
    _instance = ZaiInsightGenerator();
  }
}
