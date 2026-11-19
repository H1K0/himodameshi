// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:himo_api/src/model/pull_request.dart' as _i9;
import 'package:himo_api/src/model/push_request.dart' as _i7;
import 'package:himo_api/src/operation/sync_pull.dart' as _i3;
import 'package:himo_api/src/operation/sync_push.dart' as _i2;
import 'package:himo_api/src/response_wrapper/sync_pull_response.dart' as _i8;
import 'package:himo_api/src/response_wrapper/sync_push_response.dart' as _i6;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i5;

/// Синхронизация с приложением (HUB-7, `docs/spec/hub/sync.md`)
class SyncApi {
  SyncApi(_i1.Server server)
    : _syncPush = _i2.SyncPush(server.dio),
      _syncPull = _i3.SyncPull(server.dio);

  final _i2.SyncPush _syncPush;

  final _i3.SyncPull _syncPull;

  /// Выгрузить кабели, правки и тесты
  /// Новые кабели, правки атрибутов и новые тесты одним пакетом, из любых команд пользователя,
  /// не больше 100 объектов в сумме. Порядок обработки: кабели → правки → тесты.
  ///
  /// Пакет обрабатывается в одной транзакции, у каждого объекта — своя точка сохранения:
  /// отклонённый объект не мешает остальным, принятые фиксируются вместе.
  /// Ответ — всегда `200` с результатом по каждому объекту.
  ///
  /// Повтор теста с тем же ID и содержимым принимается с тем же результатом; другое содержимое —
  /// `id_conflict`. Повтор нового кабеля в той же команде принимается, в ответе — актуальное состояние.
  ///
  /// Подробно — `docs/spec/hub/sync.md`, раздел 3.
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
  _i4.Future<_i5.TonikResult<_i6.SyncPushResponse>> syncPush({
    required _i7.PushRequest body,
  }) async => _syncPush(body: body);

  /// Получить изменения отслеживаемых кабелей
  /// Изменения кабелей из списка `cables` с номером изменения больше `cursor`: изменённые кабели,
  /// новые и изменённые тесты (до 100, по возрастанию номера) и кабели, которых в команде больше нет.
  /// Ответ строится по одному снимку БД. Пока `has_more = true`, запрос повторяется с новым курсором.
  ///
  /// Первая загрузка кабеля — тот же запрос с `cursor: 0` и одним этим кабелем.
  /// Правило курсора при первой загрузке — `docs/spec/hub/sync.md`, раздел 6.1.
  ///
  /// `POST`, а не `GET`, потому что список отслеживаемых кабелей не помещается в адрес (ADR-023).
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
  /// Response 403 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Forbidden",
  ///   "status": 403,
  ///   "code": "no_team_access",
  ///   "detail": "Вы не состоите в этой команде"
  /// }
  /// ```
  _i4.Future<_i5.TonikResult<_i8.SyncPullResponse>> syncPull({
    required _i9.PullRequest body,
  }) async => _syncPull(body: body);
}
