// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:himo_api/src/model/change_password_request.dart' as _i15;
import 'package:himo_api/src/model/telegram_auth_data.dart' as _i17;
import 'package:himo_api/src/model/update_profile_request.dart' as _i13;
import 'package:himo_api/src/operation/change_password.dart' as _i5;
import 'package:himo_api/src/operation/delete_me.dart' as _i3;
import 'package:himo_api/src/operation/get_me.dart' as _i2;
import 'package:himo_api/src/operation/link_telegram.dart' as _i6;
import 'package:himo_api/src/operation/unlink_telegram.dart' as _i7;
import 'package:himo_api/src/operation/update_me.dart' as _i4;
import 'package:himo_api/src/response_wrapper/change_password_response.dart'
    as _i14;
import 'package:himo_api/src/response_wrapper/delete_me_response.dart' as _i11;
import 'package:himo_api/src/response_wrapper/get_me_response.dart' as _i10;
import 'package:himo_api/src/response_wrapper/link_telegram_response.dart'
    as _i16;
import 'package:himo_api/src/response_wrapper/unlink_telegram_response.dart'
    as _i18;
import 'package:himo_api/src/response_wrapper/update_me_response.dart' as _i12;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// Профиль пользователя (HUB-1)
class ProfileApi {
  ProfileApi(_i1.Server server)
    : _getMe = _i2.GetMe(server.dio),
      _deleteMe = _i3.DeleteMe(server.dio),
      _updateMe = _i4.UpdateMe(server.dio),
      _changePassword = _i5.ChangePassword(server.dio),
      _linkTelegram = _i6.LinkTelegram(server.dio),
      _unlinkTelegram = _i7.UnlinkTelegram(server.dio);

  final _i2.GetMe _getMe;

  final _i3.DeleteMe _deleteMe;

  final _i4.UpdateMe _updateMe;

  final _i5.ChangePassword _changePassword;

  final _i6.LinkTelegram _linkTelegram;

  final _i7.UnlinkTelegram _unlinkTelegram;

  /// Профиль текущего пользователя
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
  _i8.Future<_i9.TonikResult<_i10.GetMeResponse>> getMe() async => _getMe();

  /// Удаление учётной записи
  /// Учётная запись обезличивается: тесты и записи журнала остаются с автором «Удалённый пользователь»,
  /// все сеансы удаляются. Владелец команды с другими участниками сначала передаёт владение
  /// (`owner_with_members`). Личное пространство и остальные команды пользователя, где он владелец
  /// и других участников нет (а также уже удалённые его команды), удаляются вместе с учётной записью.
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
  _i8.Future<_i9.TonikResult<_i11.DeleteMeResponse>> deleteMe() async =>
      _deleteMe();

  /// Смена ника
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
  _i8.Future<_i9.TonikResult<_i12.UpdateMeResponse>> updateMe({
    required _i13.UpdateProfileRequest body,
  }) async => _updateMe(body: body);

  /// Смена пароля
  /// Все сеансы пользователя, кроме текущего, завершаются.
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
  _i8.Future<_i9.TonikResult<_i14.ChangePasswordResponse>> changePassword({
    required _i15.ChangePasswordRequest body,
  }) async => _changePassword(body: body);

  /// Привязка Telegram
  /// Только веб. Данные виджета проверяются так же, как при входе через Telegram.
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
  _i8.Future<_i9.TonikResult<_i16.LinkTelegramResponse>> linkTelegram({
    required _i17.TelegramAuthData body,
  }) async => _linkTelegram(body: body);

  /// Отвязка Telegram
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
  _i8.Future<_i9.TonikResult<_i18.UnlinkTelegramResponse>>
  unlinkTelegram() async => _unlinkTelegram();
}
