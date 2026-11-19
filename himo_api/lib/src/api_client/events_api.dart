// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i6;
import 'package:himo_api/src/operation/list_events.dart' as _i2;
import 'package:himo_api/src/response_wrapper/list_events_response.dart' as _i5;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i4;

/// Журнал действий команды (HUB-9)
class EventsApi {
  EventsApi(_i1.Server server) : _listEvents = _i2.ListEvents(server.dio);

  final _i2.ListEvents _listEvents;

  /// Журнал действий команды
  /// Сначала новые. Журнал кабеля — фильтр `cable_id`.
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
  _i3.Future<_i4.TonikResult<_i5.ListEventsResponse>> listEvents({
    required _i6.Uuid teamId,
    _i3.String? event,
    _i6.Uuid? actorId,
    _i6.Uuid? cableId,
    _i3.int limit = _i2.ListEvents.limitDefault,
    _i3.int offset = _i2.ListEvents.offsetDefault,
  }) async => _listEvents(
    teamId: teamId,
    event: event,
    actorId: actorId,
    cableId: cableId,
    limit: limit,
    offset: offset,
  );
}
