// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:himo_api/src/model/insight_request.dart' as _i7;
import 'package:himo_api/src/model/uuid.dart' as _i9;
import 'package:himo_api/src/operation/create_insight.dart' as _i2;
import 'package:himo_api/src/operation/get_test_insight.dart' as _i3;
import 'package:himo_api/src/response_wrapper/create_insight_response.dart'
    as _i6;
import 'package:himo_api/src/response_wrapper/get_test_insight_response.dart'
    as _i8;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i5;

/// ИИ-комментарии (HUB-10, ADR-018)
class InsightsApi {
  InsightsApi(_i1.Server server)
    : _createInsight = _i2.CreateInsight(server.dio),
      _getTestInsight = _i3.GetTestInsight(server.dio);

  final _i2.CreateInsight _createInsight;

  final _i3.GetTestInsight _getTestInsight;

  /// Комментарий к результатам теста
  /// Без учётной записи. Повторный запрос с теми же данными возвращает тот же комментарий
  /// без обращения к модели. Ограничения: частота запросов с одного IP (`rate_limited`)
  /// и общий дневной лимит обращений к модели (`insights_unavailable`).
  ///
  ///
  /// Response 400 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Bad Request",
  ///   "status": 400,
  ///   "code": "validation_error",
  ///   "detail": "Запрос не прошёл проверку",
  ///   "errors": [
  ///     {
  ///       "field": "name",
  ///       "message": "не может быть пустым"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Response 429 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Too Many Requests",
  ///   "status": 429,
  ///   "code": "rate_limited"
  /// }
  /// ```
  ///
  /// Response 503 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Service Unavailable",
  ///   "status": 503,
  ///   "code": "insights_unavailable",
  ///   "detail": "Комментарии временно недоступны, попробуйте позже"
  /// }
  /// ```
  _i4.Future<_i5.TonikResult<_i6.CreateInsightResponse>> createInsight({
    required _i7.InsightRequest body,
  }) async => _createInsight(body: body);

  /// Комментарий к тесту
  /// Для веба. Если комментарий уже привязан к тесту — возвращает его. Если нет — запрашивает
  /// его так же, как `POST /api/v1/insights`, привязывает к тесту и возвращает.
  /// Привязанный комментарий больше не меняется.
  ///
  ///
  /// Response 401 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Unauthorized",
  ///   "status": 401,
  ///   "code": "unauthorized"
  /// }
  /// ```
  ///
  /// Response 404 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Not Found",
  ///   "status": 404,
  ///   "code": "not_found"
  /// }
  /// ```
  ///
  /// Response 429 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Too Many Requests",
  ///   "status": 429,
  ///   "code": "rate_limited"
  /// }
  /// ```
  ///
  /// Response 503 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Service Unavailable",
  ///   "status": 503,
  ///   "code": "insights_unavailable",
  ///   "detail": "Комментарии временно недоступны, попробуйте позже"
  /// }
  /// ```
  _i4.Future<_i5.TonikResult<_i8.GetTestInsightResponse>> getTestInsight({
    required _i9.Uuid testId,
  }) async => _getTestInsight(testId: testId);
}
