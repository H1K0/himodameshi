// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i12;

import 'package:himo_api/src/model/create_team_request.dart' as _i16;
import 'package:himo_api/src/model/transfer_ownership_request.dart' as _i24;
import 'package:himo_api/src/model/update_team_request.dart' as _i21;
import 'package:himo_api/src/model/uuid.dart' as _i18;
import 'package:himo_api/src/operation/create_team.dart' as _i3;
import 'package:himo_api/src/operation/delete_team.dart' as _i5;
import 'package:himo_api/src/operation/get_team.dart' as _i4;
import 'package:himo_api/src/operation/leave_team.dart' as _i9;
import 'package:himo_api/src/operation/list_members.dart' as _i10;
import 'package:himo_api/src/operation/list_teams.dart' as _i2;
import 'package:himo_api/src/operation/remove_member.dart' as _i11;
import 'package:himo_api/src/operation/restore_team.dart' as _i7;
import 'package:himo_api/src/operation/transfer_ownership.dart' as _i8;
import 'package:himo_api/src/operation/update_team.dart' as _i6;
import 'package:himo_api/src/response_wrapper/create_team_response.dart'
    as _i15;
import 'package:himo_api/src/response_wrapper/delete_team_response.dart'
    as _i19;
import 'package:himo_api/src/response_wrapper/get_team_response.dart' as _i17;
import 'package:himo_api/src/response_wrapper/leave_team_response.dart' as _i25;
import 'package:himo_api/src/response_wrapper/list_members_response.dart'
    as _i26;
import 'package:himo_api/src/response_wrapper/list_teams_response.dart' as _i14;
import 'package:himo_api/src/response_wrapper/remove_member_response.dart'
    as _i27;
import 'package:himo_api/src/response_wrapper/restore_team_response.dart'
    as _i22;
import 'package:himo_api/src/response_wrapper/transfer_ownership_response.dart'
    as _i23;
import 'package:himo_api/src/response_wrapper/update_team_response.dart'
    as _i20;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i13;

/// Команды и участники (HUB-2, HUB-3)
class TeamsApi {
  TeamsApi(_i1.Server server)
    : _listTeams = _i2.ListTeams(server.dio),
      _createTeam = _i3.CreateTeam(server.dio),
      _getTeam = _i4.GetTeam(server.dio),
      _deleteTeam = _i5.DeleteTeam(server.dio),
      _updateTeam = _i6.UpdateTeam(server.dio),
      _restoreTeam = _i7.RestoreTeam(server.dio),
      _transferOwnership = _i8.TransferOwnership(server.dio),
      _leaveTeam = _i9.LeaveTeam(server.dio),
      _listMembers = _i10.ListMembers(server.dio),
      _removeMember = _i11.RemoveMember(server.dio);

  final _i2.ListTeams _listTeams;

  final _i3.CreateTeam _createTeam;

  final _i4.GetTeam _getTeam;

  final _i5.DeleteTeam _deleteTeam;

  final _i6.UpdateTeam _updateTeam;

  final _i7.RestoreTeam _restoreTeam;

  final _i8.TransferOwnership _transferOwnership;

  final _i9.LeaveTeam _leaveTeam;

  final _i10.ListMembers _listMembers;

  final _i11.RemoveMember _removeMember;

  /// Мои команды
  /// Команды, в которых состоит пользователь, включая личное пространство.
  /// С `deleted=true` — удалённые за последние 30 суток команды, где пользователь владелец
  /// (для восстановления).
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
  _i12.Future<_i13.TonikResult<_i14.ListTeamsResponse>> listTeams({
    _i12.bool deleted = _i2.ListTeams.deletedDefault,
  }) async => _listTeams(deleted: deleted);

  /// Создать команду
  /// Создатель становится владельцем.
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
  _i12.Future<_i13.TonikResult<_i15.CreateTeamResponse>> createTeam({
    required _i16.CreateTeamRequest body,
  }) async => _createTeam(body: body);

  /// Команда
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
  _i12.Future<_i13.TonikResult<_i17.GetTeamResponse>> getTeam({
    required _i18.Uuid teamId,
  }) async => _getTeam(teamId: teamId);

  /// Удалить команду
  /// Только владелец. Команда со всеми кабелями и тестами перестаёт быть доступной;
  /// восстановить её можно в течение 30 суток. Подтверждение вводом названия — в интерфейсе.
  /// Личное пространство удалить нельзя (`personal_team`).
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
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i12.Future<_i13.TonikResult<_i19.DeleteTeamResponse>> deleteTeam({
    required _i18.Uuid teamId,
  }) async => _deleteTeam(teamId: teamId);

  /// Название и описание команды
  /// Только владелец. Переданные поля заменяются, отсутствующие не меняются.
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
  _i12.Future<_i13.TonikResult<_i20.UpdateTeamResponse>> updateTeam({
    required _i21.UpdateTeamRequest body,
    required _i18.Uuid teamId,
  }) async => _updateTeam(body: body, teamId: teamId);

  /// Восстановить удалённую команду
  /// Только владелец, в течение 30 суток после удаления.
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
  _i12.Future<_i13.TonikResult<_i22.RestoreTeamResponse>> restoreTeam({
    required _i18.Uuid teamId,
  }) async => _restoreTeam(teamId: teamId);

  /// Передать владение
  /// Только владелец. Прежний владелец становится участником.
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
  ///
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i12.Future<_i13.TonikResult<_i23.TransferOwnershipResponse>>
  transferOwnership({
    required _i24.TransferOwnershipRequest body,
    required _i18.Uuid teamId,
  }) async => _transferOwnership(body: body, teamId: teamId);

  /// Выйти из команды
  /// Владелец выходит только после передачи владения (`owner_cannot_leave`),
  /// из личного пространства выйти нельзя (`personal_team`).
  /// Пользователь перестаёт быть ответственным за кабели команды.
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
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i12.Future<_i13.TonikResult<_i25.LeaveTeamResponse>> leaveTeam({
    required _i18.Uuid teamId,
  }) async => _leaveTeam(teamId: teamId);

  /// Участники команды
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
  _i12.Future<_i13.TonikResult<_i26.ListMembersResponse>> listMembers({
    required _i18.Uuid teamId,
  }) async => _listMembers(teamId: teamId);

  /// Исключить участника
  /// Только владелец; исключить себя нельзя (`owner_cannot_leave`).
  /// Доступ участника к данным команды закрывается сразу, он перестаёт быть ответственным за кабели.
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
  ///
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i12.Future<_i13.TonikResult<_i27.RemoveMemberResponse>> removeMember({
    required _i18.Uuid teamId,
    required _i18.Uuid userId,
  }) async => _removeMember(teamId: teamId, userId: userId);
}
