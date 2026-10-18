/// Базовое исключение InsightGenerator.
/// Все специфические ошибки наследуются от него.
abstract class InsightException implements Exception {
  final String message;
  const InsightException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Ошибка сети: нет соединения, таймаут, DNS, TLS.
class InsightNetworkException extends InsightException {
  const InsightNetworkException(super.message);
}

/// Ошибка авторизации: 401, 403. Повтор не поможет — нужно менять ключ.
class InsightAuthException extends InsightException {
  const InsightAuthException(super.message);
}

/// Превышен лимит запросов: 429.
class InsightRateLimitException extends InsightException {
  const InsightRateLimitException(super.message);
}

/// Ошибка на стороне сервера: 5xx.
class InsightServerException extends InsightException {
  const InsightServerException(super.message);
}

/// Прочие ошибки, которые не удалось классифицировать.
class InsightUnknownException extends InsightException {
  const InsightUnknownException(super.message);
}