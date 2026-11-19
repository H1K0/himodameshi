// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i7;

import 'package:himo_api/src/model/create_invitation_request.dart' as _i12;
import 'package:himo_api/src/model/uuid.dart' as _i10;
import 'package:himo_api/src/operation/accept_invitation.dart' as _i6;
import 'package:himo_api/src/operation/create_invitation.dart' as _i3;
import 'package:himo_api/src/operation/get_invitation_by_token.dart' as _i5;
import 'package:himo_api/src/operation/list_invitations.dart' as _i2;
import 'package:himo_api/src/operation/revoke_invitation.dart' as _i4;
import 'package:himo_api/src/response_wrapper/accept_invitation_response.dart'
    as _i15;
import 'package:himo_api/src/response_wrapper/create_invitation_response.dart'
    as _i11;
import 'package:himo_api/src/response_wrapper/get_invitation_by_token_response.dart'
    as _i14;
import 'package:himo_api/src/response_wrapper/list_invitations_response.dart'
    as _i9;
import 'package:himo_api/src/response_wrapper/revoke_invitation_response.dart'
    as _i13;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i8;

/// Приглашения в команду (HUB-2)
class InvitationsApi {
  InvitationsApi(_i1.Server server)
    : _listInvitations = _i2.ListInvitations(server.dio),
      _createInvitation = _i3.CreateInvitation(server.dio),
      _revokeInvitation = _i4.RevokeInvitation(server.dio),
      _getInvitationByToken = _i5.GetInvitationByToken(server.dio),
      _acceptInvitation = _i6.AcceptInvitation(server.dio);

  final _i2.ListInvitations _listInvitations;

  final _i3.CreateInvitation _createInvitation;

  final _i4.RevokeInvitation _revokeInvitation;

  final _i5.GetInvitationByToken _getInvitationByToken;

  final _i6.AcceptInvitation _acceptInvitation;

  /// Действующие приглашения
  /// Только владелец. Истёкшие, отозванные и использованные не показываются.
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
  _i7.Future<_i8.TonikResult<_i9.ListInvitationsResponse>> listInvitations({
    required _i10.Uuid teamId,
  }) async => _listInvitations(teamId: teamId);

  /// Создать приглашение
  /// Только владелец; в личное пространство приглашать нельзя (`personal_team`).
  /// Токен возвращается один раз — на сервере хранится только его хеш.
  /// Ссылку вида `https://<домен>/invite/<token>` собирает веб.
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
  _i7.Future<_i8.TonikResult<_i11.CreateInvitationResponse>> createInvitation({
    required _i10.Uuid teamId,
    _i12.CreateInvitationRequest? body,
  }) async => _createInvitation(body: body, teamId: teamId);

  /// Отозвать приглашение
  /// Только владелец команды приглашения.
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
  _i7.Future<_i8.TonikResult<_i13.RevokeInvitationResponse>> revokeInvitation({
    required _i10.Uuid invitationId,
  }) async => _revokeInvitation(invitationId: invitationId);

  /// Куда ведёт приглашение
  /// Без входа — чтобы показать посетителю название команды до входа или регистрации.
  /// [token] Токен из ссылки-приглашения
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
  _i7.Future<_i8.TonikResult<_i14.GetInvitationByTokenResponse>>
  getInvitationByToken({required _i7.String token}) async =>
      _getInvitationByToken(token: token);

  /// Вступить в команду
  /// Приглашение одноразовое. Проверяется лимит участников по тарифу (`member_limit_reached`).
  ///
  /// [token] Токен из ссылки-приглашения
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
  _i7.Future<_i8.TonikResult<_i15.AcceptInvitationResponse>> acceptInvitation({
    required _i7.String token,
  }) async => _acceptInvitation(token: token);
}
