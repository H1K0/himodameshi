// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/response/api_v1_auth_telegram_post200_response.dart'
    as _i2;
import 'package:himo_api/src/response/too_many_requests.dart' as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class LoginTelegramResponse {
  const LoginTelegramResponse();
}

@_i1.immutable
class LoginTelegramResponse200 extends LoginTelegramResponse {
  const LoginTelegramResponse200({required this.body});

  final _i2.ApiV1AuthTelegramPost200Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginTelegramResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginTelegramResponse400 extends LoginTelegramResponse {
  const LoginTelegramResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginTelegramResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginTelegramResponse401 extends LoginTelegramResponse {
  const LoginTelegramResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginTelegramResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginTelegramResponse429 extends LoginTelegramResponse {
  const LoginTelegramResponse429({required this.body});

  final _i5.TooManyRequests body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginTelegramResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
