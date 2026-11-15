import 'package:app/data/insight_input.dart';

/// Абстрактный генератор текстового комментария к результатам теста.
///
/// В MVP реализуется через ZaiInsightGenerator (Zhipu GLM).
/// В будущем может быть заменён на HubInsightGenerator или другую
/// реализацию без изменений в UI.
abstract interface class InsightGenerator {
  /// Возвращает текстовый комментарий (1–2 предложения).
  /// Бросает исключение при ошибке — UI должен обработать.
  Future<String> generate(InsightInput input);
}
