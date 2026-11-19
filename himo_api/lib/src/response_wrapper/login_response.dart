// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/app_outdated_problem.dart' as _i5;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/response/api_v1_auth_login_post200_response.dart'
    as _i2;
import 'package:himo_api/src/response/too_many_requests.dart' as _i6;
import 'package:meta/meta.dart' as _i1;

sealed class LoginResponse {
  const LoginResponse();
}

@_i1.immutable
class LoginResponse200 extends LoginResponse {
  const LoginResponse200({required this.body});

  final _i2.ApiV1AuthLoginPost200Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginResponse400 extends LoginResponse {
  const LoginResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginResponse401 extends LoginResponse {
  const LoginResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginResponse426 extends LoginResponse {
  const LoginResponse426({required this.body});

  final _i5.AppOutdatedProblem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LoginResponse429 extends LoginResponse {
  const LoginResponse429({required this.body});

  final _i6.TooManyRequests body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
