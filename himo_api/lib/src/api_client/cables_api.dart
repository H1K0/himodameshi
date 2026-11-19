// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:himo_api/src/model/api_v1_teams_team_id_cables_parameters_model.dart'
    as _i14;
import 'package:himo_api/src/model/api_v1_teams_team_id_cables_parameters_model2.dart'
    as _i15;
import 'package:himo_api/src/model/cable_type.dart' as _i12;
import 'package:himo_api/src/model/cable_update.dart' as _i19;
import 'package:himo_api/src/model/color.dart' as _i13;
import 'package:himo_api/src/model/sort_order.dart' as _i16;
import 'package:himo_api/src/model/uuid.dart' as _i11;
import 'package:himo_api/src/operation/archive_cable.dart' as _i6;
import 'package:himo_api/src/operation/delete_cable.dart' as _i5;
import 'package:himo_api/src/operation/get_cable.dart' as _i3;
import 'package:himo_api/src/operation/list_cables.dart' as _i2;
import 'package:himo_api/src/operation/unarchive_cable.dart' as _i7;
import 'package:himo_api/src/operation/update_cable.dart' as _i4;
import 'package:himo_api/src/response_wrapper/archive_cable_response.dart'
    as _i21;
import 'package:himo_api/src/response_wrapper/delete_cable_response.dart'
    as _i20;
import 'package:himo_api/src/response_wrapper/get_cable_response.dart' as _i17;
import 'package:himo_api/src/response_wrapper/list_cables_response.dart'
    as _i10;
import 'package:himo_api/src/response_wrapper/unarchive_cable_response.dart'
    as _i22;
import 'package:himo_api/src/response_wrapper/update_cable_response.dart'
    as _i18;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// Кабели (HUB-4)
class CablesApi {
  CablesApi(_i1.Server server)
    : _listCables = _i2.ListCables(server.dio),
      _getCable = _i3.GetCable(server.dio),
      _updateCable = _i4.UpdateCable(server.dio),
      _deleteCable = _i5.DeleteCable(server.dio),
      _archiveCable = _i6.ArchiveCable(server.dio),
      _unarchiveCable = _i7.UnarchiveCable(server.dio);

  final _i2.ListCables _listCables;

  final _i3.GetCable _getCable;

  final _i4.UpdateCable _updateCable;

  final _i5.DeleteCable _deleteCable;

  final _i6.ArchiveCable _archiveCable;

  final _i7.UnarchiveCable _unarchiveCable;

  /// Каталог кабелей команды
  /// Список для веба и каталог для раздела Hub приложения. Без результатов тестов.
  /// По умолчанию — кабели не в архиве, сначала с самым свежим тестом.
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
  _i8.Future<_i9.TonikResult<_i10.ListCablesResponse>> listCables({
    required _i11.Uuid teamId,
    _i8.String? q,
    _i12.CableType? cableType,
    _i13.Color? color,
    _i14.ApiV1TeamsTeamIdCablesParametersModel? health,
    _i8.String? assignee,
    _i8.bool archived = _i2.ListCables.archivedDefault,
    _i15.ApiV1TeamsTeamIdCablesParametersModel2 sort =
        _i2.ListCables.sortDefault,
    _i16.SortOrder? order,
    _i8.int limit = _i2.ListCables.limitDefault,
    _i8.int offset = _i2.ListCables.offsetDefault,
  }) async => _listCables(
    teamId: teamId,
    q: q,
    cableType: cableType,
    color: color,
    health: health,
    assignee: assignee,
    archived: archived,
    sort: sort,
    order: order,
    limit: limit,
    offset: offset,
  );

  /// Кабель
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
  _i8.Future<_i9.TonikResult<_i17.GetCableResponse>> getCable({
    required _i11.Uuid cableId,
  }) async => _getCable(cableId: cableId);

  /// Изменить атрибуты кабеля
  /// Полная замена изменяемых атрибутов с оптимистичной блокировкой: `version` — версия,
  /// от которой сделана правка. Если кабель успел измениться, ответ `409 version_conflict`
  /// с актуальным кабелем в поле `cable`. Тип нельзя менять после первого теста
  /// (`cable_type_locked`), архивный кабель не принимает изменений (`cable_archived`),
  /// ответственный должен быть участником команды (`not_a_member`).
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
  _i8.Future<_i9.TonikResult<_i18.UpdateCableResponse>> updateCable({
    required _i19.CableUpdate body,
    required _i11.Uuid cableId,
  }) async => _updateCable(body: body, cableId: cableId);

  /// Окончательно удалить кабель
  /// Только владелец команды. Кабель удаляется со всей историей тестов безвозвратно;
  /// записи журнала остаются. Подтверждение — в интерфейсе.
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
  _i8.Future<_i9.TonikResult<_i20.DeleteCableResponse>> deleteCable({
    required _i11.Uuid cableId,
  }) async => _deleteCable(cableId: cableId);

  /// Отправить кабель в архив
  /// Архивный кабель доступен только для чтения. Повтор для архивного кабеля отвечает его состоянием.
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
  _i8.Future<_i9.TonikResult<_i21.ArchiveCableResponse>> archiveCable({
    required _i11.Uuid cableId,
  }) async => _archiveCable(cableId: cableId);

  /// Вернуть кабель из архива
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
  _i8.Future<_i9.TonikResult<_i22.UnarchiveCableResponse>> unarchiveCable({
    required _i11.Uuid cableId,
  }) async => _unarchiveCable(cableId: cableId);
}
