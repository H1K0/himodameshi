import 'dart:convert';
import 'package:app/domain/insight_generator.dart';
import 'package:http/http.dart' as http;
import 'test_models.dart';
import 'insight_input.dart';
import 'package:app/domain/insight_exceptions.dart';

/// Генератор текстового заключения о состоянии кабеля через LLM (Zhipu GLM).
///
/// Вызывается при открытии DetailsScreen после завершения теста.
/// Ответ кэшируется в памяти по ключу из входных данных — повторное
/// открытие экрана с теми же числами не дёргает API.
class ZaiInsightGenerator implements InsightGenerator {
  static const String _apiKey = String.fromEnvironment('ZAI_API_KEY');
  static const String _endpoint =
      'https://api.z.ai/api/paas/v4/chat/completions';
  static const String _model = 'glm-4.7-flash';

  /// In-memory кэш ответов. Живёт до перезапуска приложения.
  static final Map<String, String> _cache = {};

  static const String _systemPrompt = """Ты — технический эксперт по аудиокабелям. Ты пишешь короткий понятный
комментарий для музыканта или звукорежиссёра — человека, который понимает
звук, но не хочет читать отчёт по каждому тесту.

На вход приходят:
- Результаты трёх тестов (Целостность, CMRR, АЧХ) с числами и нормами
- Итоговое здоровье кабеля в процентах (0–100)

Твоя задача — на основе этих данных написать ОДИН короткий вывод:
1–3 предложения. Не больше.

ПРАВИЛА:
- Не пересказывай тесты по отдельности. Только общий вывод.
- Первое предложение — состояние кабеля простыми словами.
- Второе (если нужно) — как это скажется на звуке или для чего кабель годится.
- Можешь упомянуть конкретную цифру (например, здоровье или проблемный
  параметр), но без перегруза.
- Привязывай вывод к реальным задачам: гитара, вокал, студия, сцена, длинные
  трассы — если это уместно.
- Тон — спокойный, дружелюбный, как у знающего коллеги. Без паники и восторгов.
- Если всё в норме — скажи об этом прямо и коротко.
- Если есть проблема — назови её суть, но не запугивай.
- Если напротив теста указано «не тестировано» — значит, тест не проводился, и его
  результат НЕ участвует в расчёте итогового здоровья. Не оценивай этот параметр
  и не строй догадок о нём. Если из-за этого итоговая оценка неполная — можешь
  коротко об этом упомянуть.
- Если данных мало — честно скажи об этом.

ФОРМАТ ОТВЕТА:
Только текст, 1–3 предложения. Без заголовков, списков, markdown и JSON.

ПРИМЕР ХОРОШЕГО ОТВЕТА:
"Кабель ровно передаёт всю слышимую полосу до 20 кГц с минимальными потерями.
Для гитары, вокала и большинства инструментов — отличный результат."

ПРИМЕР ХОРОШЕГО ОТВЕТА С ПРОБЛЕМОЙ:
"Кабель рабочий и хорошо передаёт частоты, но слабо защищён от помех — рядом
с блоками питания или на длинных трассах может появиться фоновый шум.""";

  /// Генерирует заключение. Бросает исключение при ошибке —
  /// вызывающая сторона (DetailsScreen) должна показать заглушку.
  @override
  Future<String> generate(InsightInput input) async {
    if (_apiKey.isEmpty) {
      throw const InsightAuthException(
        'ZAI_API_KEY не задан. Запустите приложение с '
            '--dart-define-from-file=config/dev.json',
      );
    }

    final cacheKey = _buildCacheKey(input);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final userPrompt = _buildUserPrompt(input);

    final http.Response response;
    try {
      response = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
        }),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw const InsightNetworkException(
          'Тайм-аут запроса LLM через 20 с.',
        ),
      );
    } on InsightException {
      rethrow;
    } catch (e) {
      // SocketException, HandshakeException, DNS-ошибки и т. п.
      throw InsightNetworkException('Ошибка сети LLM: $e');
    }

    // Классификация по HTTP-коду
    switch (response.statusCode) {
      case 200:
        break; // продолжим ниже
      case 401:
      case 403:
        throw InsightAuthException(
          'Ошибка аутентификации LLM: ${response.statusCode} ${response.body}',
        );
      case 429:
        throw InsightRateLimitException(
          'Превышен лимит запросов к LLM(429): ${response.body}',
        );
      default:
        if (response.statusCode >= 500) {
          throw InsightServerException(
            'Ошибка сервера LLM: ${response.statusCode} ${response.body}',
          );
        }
        throw InsightUnknownException(
          'Запрос LLM не выполнен: ${response.statusCode} ${response.body}',
        );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final content = data['choices']?[0]?['message']?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const InsightUnknownException('LLM вернул пустое содержимое');
    }

    final result = content.trim();
    _cache[cacheKey] = result;
    return result;
  }

  // --------------------------------------------------------------------------
  // Приватные методы
  // --------------------------------------------------------------------------

  String _buildCacheKey(InsightInput input) {
    return '${input.cableType}|${input.healthScore}|'
        '${input.continuity?.min}|${input.continuity?.max}|'
        '${input.cmrr?.valueDb}|'
        '${input.freq?.peak}|${input.freq?.sigma}|${input.freq?.noSignal}';
  }

  String _buildUserPrompt(InsightInput input) {
    final buffer = StringBuffer();
    buffer.writeln('Результаты измерений:');
    buffer.writeln('- Тип кабеля: ${_cableTypeLabel(input.cableType)}');

    // Целостность
    if (input.continuity != null) {
      final c = input.continuity!;
      final range = c.min == c.max
          ? '${c.min.toStringAsFixed(2)} Ом'
          : '${c.min.toStringAsFixed(2)}–${c.max.toStringAsFixed(2)} Ом';
      buffer.writeln('- Целостность: $range (шкала: отлично < 5 Ом, удовл. 5–50 Ом, плохо > 50 Ом)');
    } else {
      buffer.writeln('- Целостность: не тестировано');
    }

    // CMRR
    if (input.cmrr != null) {
      buffer.writeln(
        '- CMRR: ${input.cmrr!.valueDb.toStringAsFixed(1)} дБ (шкала: плохо < 40, удовл. 40–60, отлично > 60)',
      );
    } else {
      buffer.writeln('- CMRR: не тестировано');
    }

    // АЧХ
    if (input.freq != null) {
      if (input.freq!.noSignal) {
        buffer.writeln('- АЧХ: нет сигнала');
      } else if (input.freq!.peak != null && input.freq!.sigma != null) {
        buffer.writeln(
          '- АЧХ: пик отклонения ${input.freq!.peak!.toStringAsFixed(1)} дБ, '
              'σ ${input.freq!.sigma!.toStringAsFixed(1)} дБ (шкала: отлично ≤ ±1 дБ, удовл. ≤ ±3 дБ, плохо > ±3 дБ)',
        );
      } else {
        buffer.writeln('- АЧХ: не тестировано');
      }
    } else {
      buffer.writeln('- АЧХ: не тестировано');
    }

    // Здоровье
    if (input.healthScore != null) {
      buffer.writeln('- Итоговое здоровье: ${input.healthScore}%');
    } else {
      buffer.writeln('- Итоговое здоровье: не рассчитано');
    }

    return buffer.toString();
  }

  String _cableTypeLabel(CableType type) {
    switch (type) {
      case CableType.xlr:
        return 'XLR (балансный)';
      case CableType.jackTrs:
        return 'Jack TRS (балансный)';
      case CableType.jackTs:
        return 'Jack TS (небалансный)';
    }
  }
}