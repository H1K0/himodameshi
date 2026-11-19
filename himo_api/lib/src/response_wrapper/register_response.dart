// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/response/api_v1_auth_register_post201_response.dart'
    as _i2;
import 'package:himo_api/src/response/too_many_requests.dart' as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RegisterResponse {
  const RegisterResponse();
}

@_i1.immutable
class RegisterResponse201 extends RegisterResponse {
  const RegisterResponse201({required this.body});

  final _i2.ApiV1AuthRegisterPost201Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class RegisterResponse400 extends RegisterResponse {
  const RegisterResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class RegisterResponse409 extends RegisterResponse {
  const RegisterResponse409({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class RegisterResponse429 extends RegisterResponse {
  const RegisterResponse429({required this.body});

  final _i5.TooManyRequests body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
