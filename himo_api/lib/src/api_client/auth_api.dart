// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i7;

import 'package:himo_api/src/model/login_request.dart' as _i12;
import 'package:himo_api/src/model/register_request.dart' as _i10;
import 'package:himo_api/src/model/telegram_auth_data.dart' as _i14;
import 'package:himo_api/src/operation/login.dart' as _i3;
import 'package:himo_api/src/operation/login_telegram.dart' as _i4;
import 'package:himo_api/src/operation/logout.dart' as _i5;
import 'package:himo_api/src/operation/logout_all.dart' as _i6;
import 'package:himo_api/src/operation/register.dart' as _i2;
import 'package:himo_api/src/response_wrapper/login_response.dart' as _i11;
import 'package:himo_api/src/response_wrapper/login_telegram_response.dart'
    as _i13;
import 'package:himo_api/src/response_wrapper/logout_all_response.dart' as _i16;
import 'package:himo_api/src/response_wrapper/logout_response.dart' as _i15;
import 'package:himo_api/src/response_wrapper/register_response.dart' as _i9;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i8;

/// Регистрация, вход и сеансы (HUB-1, ADR-022)
class AuthApi {
  AuthApi(_i1.Server server)
    : _register = _i2.Register(server.dio),
      _login = _i3.Login(server.dio),
      _loginTelegram = _i4.LoginTelegram(server.dio),
      _logout = _i5.Logout(server.dio),
      _logoutAll = _i6.LogoutAll(server.dio);

  final _i2.Register _register;

  final _i3.Login _login;

  final _i4.LoginTelegram _loginTelegram;

  final _i5.Logout _logout;

  final _i6.LogoutAll _logoutAll;

  /// Регистрация
  /// Создаёт учётную запись и личное пространство и сразу открывает сеанс.
  /// Для `client: web` токен приходит в cookie, для `client: app` — в теле ответа.
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
  _i7.Future<_i8.TonikResult<_i9.RegisterResponse>> register({
    required _i10.RegisterRequest body,
  }) async => _register(body: body);

  /// Вход по нику и паролю
  /// Для `client: web` токен приходит в cookie, для `client: app` — в теле ответа.
  /// Для несуществующего ника и неверного пароля ответ одинаковый.
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
  _i7.Future<_i8.TonikResult<_i11.LoginResponse>> login({
    required _i12.LoginRequest body,
  }) async => _login(body: body);

  /// Вход через Telegram Login Widget
  /// Только веб. SPA передаёт объект, полученный от виджета, без изменений.
  /// Сервер проверяет подпись и свежесть `auth_date` (не старше суток) и открывает веб-сеанс.
  /// Регистрации через Telegram нет: если Telegram не привязан, ответ `telegram_not_linked`.
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
  _i7.Future<_i8.TonikResult<_i13.LoginTelegramResponse>> loginTelegram({
    required _i14.TelegramAuthData body,
  }) async => _loginTelegram(body: body);

  /// Завершить текущий сеанс
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
  _i7.Future<_i8.TonikResult<_i15.LogoutResponse>> logout() async => _logout();

  /// Завершить все сеансы
  /// Завершает все сеансы пользователя, включая текущий, — например, при утере телефона.
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
  _i7.Future<_i8.TonikResult<_i16.LogoutAllResponse>> logoutAll() async =>
      _logoutAll();
}
